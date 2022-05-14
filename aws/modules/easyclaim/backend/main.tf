locals {
  container_name = "backend"
  #  timestamp      = "2021-03-17T09:01:11Z"
  timestamp = timestamp()
  tags = merge(
    var.tags,
    {
      Name          = var.name
      "billing-app" = "backend"
    }
  )
}

resource "aws_cloudwatch_log_group" "log-group" {
  name              = var.name
  retention_in_days = var.log_retention_days
  tags = merge(
    local.tags,
    {
      Name = var.name
    }
  )
}

# for `awslogs` logging driver
# configuration in ecs-services
#
data "aws_region" "current" {}

module "task" {
  source = "../../ecs/task"

  name                  = var.name
  cpu                   = 512
  memory                = 1024
  task_role_arn         = module.task_role.arn
  container_definitions = <<EOF
  [
    {
      "name": "${local.container_name}",
      "image": "${var.image}",
      "essential": true,
      "cpu": 0,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.name}",
          "awslogs-region": "${data.aws_region.current.name}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "environment": [
        { "name": "APP", "value": "${var.name}" }
      ],
      "mountPoints": [],
      "volumesFrom": [],
      "portMappings": [
        {
          "containerPort": ${var.port},
          "hostPort": ${var.port},
          "protocol": "tcp"
        }
      ],
      "stopTimeout": ${var.stop_timeout}
    }
  ]
  EOF

  tags = local.tags
}

module "service" {
  source = "../../ecs/service"
  name                           = var.name
  security_groups                = var.security_groups
  cluster_id                     = var.cluster.id
  subnet_ids                     = var.subnet_ids

  container_name   = local.container_name
  container_port   = var.port
  target_group_arn = aws_lb_target_group.main.arn

  task_definition_arn = module.task.arn

  tags = local.tags
}

module "autoscaling" {
  source = "../../ecs/headless-autoscaling-step-cpu"

  count = var.enable_backend_autoscaling ? 1 : 0
  name         = var.name
  cluster_name = var.cluster.name
  service_name = module.service.name
  min_capacity = var.backend_min_capacity
  max_capacity = var.backend_max_capacity
  tags         = local.tags
}