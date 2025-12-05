
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project_name}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "${var.project_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_db_instance" "prefect_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "17.5"
  instance_class       = "db.t3.micro"
  db_name              = "prefect"
  username             = "prefect"
  password             = random_password.db_password.result
  parameter_group_name = "default.postgres17"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name = aws_db_subnet_group.prefect.name
}

resource "aws_db_subnet_group" "prefect" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Allow access to the Prefect database"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.prefect_server.id]
  }
}

resource "aws_ecs_cluster" "prefect_cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_task_definition" "prefect_server" {
  family                   = "${var.project_name}-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "prefect-server"
      image     = "prefecthq/prefect:3-latest"
      command   = ["prefect", "server", "start", "--host", "0.0.0.0"]
      essential = true
      portMappings = [
        {
          containerPort = 4200
          hostPort      = 4200
        }
      ]
      environment = [
        {
          name  = "PREFECT_API_DATABASE_CONNECTION_URL"
          value = "postgresql+asyncpg://prefect:${random_password.db_password.result}@${aws_db_instance.prefect_db.address}:5432/prefect"
        }
      ]
      secrets = [
        {
          name      = "PREFECT_API_DATABASE_PASSWORD"
          valueFrom = aws_secretsmanager_secret_version.db_password.arn
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "prefect_server" {
  name            = "${var.project_name}-server-service"
  cluster         = aws_ecs_cluster.prefect_cluster.id
  task_definition = aws_ecs_task_definition.prefect_server.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.prefect_server.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.prefect_server.arn
    container_name   = "prefect-server"
    container_port   = 4200
  }
}

resource "aws_security_group" "prefect_server" {
  name        = "${var.project_name}-server-sg"
  description = "Allow access to the Prefect server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "prefect" {
  name               = "${var.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "prefect_server" {
  name     = "${var.project_name}-server-tg"
  port     = 4200
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "prefect_server" {
  load_balancer_arn = aws_lb.prefect.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prefect_server.arn
  }
}

resource "aws_security_group" "lb" {
  name        = "${var.project_name}-lb-sg"
  description = "Allow HTTP access to the load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "prefect_worker" {
  family                   = "${var.project_name}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "prefect-worker"
      image     = "prefecthq/prefect:3-latest"
      command   = ["prefect", "worker", "start", "--pool", "process-pool"]
      essential = true
      environment = [
        {
          name  = "PREFECT_API_URL"
          value = "http://${aws_lb.prefect.dns_name}/api"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "prefect_worker" {
  name            = "${var.project_name}-worker-service"
  cluster         = aws_ecs_cluster.prefect_cluster.id
  task_definition = aws_ecs_task_definition.prefect_worker.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.prefect_worker.id]
  }
}

resource "aws_security_group" "prefect_worker" {
  name        = "${var.project_name}-worker-sg"
  description = "Allow access for the Prefect worker"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_read_only" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
