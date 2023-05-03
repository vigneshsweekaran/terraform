locals {
  container_image = "sonarqube:9.9.0-community"
  container_name  = "sonarqube"
  container_port  = "8080"
  db_password     = "sonarPassword"
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Ecs clsuter
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "4.1.3"

  cluster_name = var.cluster_name
  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }
  tags = local.tags
}

resource "aws_cloudwatch_log_group" "log-group" {
  name              = "sonarqube"
  tags = local.tags
}

# Task definition
resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "sonarqube"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions    = <<EOF
  [
    {
      "name": "sonarqube",
      "image": "sonarqube:9.9.0-community",
      "cpu": 1024,
      "memory": 2048,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 9000,
          "hostPort": 9000
        }
      ],
      "environment": [
        {"name": "SONAR_JDBC_URL", "value": "jdbc:postgresql://${aws_db_instance.sonarqube.endpoint}"},
        {"name": "SONAR_JDBC_USERNAME", "value": "sonar"}
      ],
      "secrets": [
        {
          "name": "SONAR_JDBC_PASSWORD",
          "valueFrom": "${aws_ssm_parameter.rds.arn}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  EOF

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

# ECS Service
resource "aws_ecs_service" "sonarqube" {
  name            = "sonarqube"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.sonarqube.arn
  desired_count   = 1
  load_balancer {
    target_group_arn = aws_lb_target_group.sonarqube.arn
    container_name   = "sonarqube"
    container_port   = "9000"
  }
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = true
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE"
    weight            = 50
  }
  capacity_provider_strategy {
    base              = 0
    capacity_provider = "FARGATE_SPOT"
    weight            = 50
  }
}

resource "aws_lb" "sonarqube" {
  name                       = "sonarqube"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  security_groups            = [aws_security_group.lb.id]
  subnets                    = data.aws_subnets.default.ids
  tags                       = local.tags
}

resource "aws_lb_target_group" "sonarqube" {
  name_prefix = "sonar"
  port        = "9000"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
  health_check {
    path    = "/"
    matcher = 200
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.sonarqube.arn
  port              = "9000"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube.arn
  }
}

#RDS
resource "aws_db_instance" "sonarqube" {
  allocated_storage           = 10
  db_name                     = "sonarqube"
  engine                      = "postgres"
  engine_version              = "13.8"
  instance_class              = "db.t3.micro"
  publicly_accessible         = true
  password                    = local.db_password
  username                    = "sonar"
  parameter_group_name        = aws_db_parameter_group.sonarqube.name
}

resource "aws_db_parameter_group" "sonarqube" {
  name   = "sonarqube"
  family = "postgres13"
  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_ssm_parameter" "rds" {
  name  = "/dev/db/password"
  type  = "String"
  value = local.db_password
}
