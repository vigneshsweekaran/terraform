provider "aws" {}

locals {
  container_name = "hello-world"
  timestamp = timestamp()
  tags = merge(
    var.tags,
    {
      name = var.name
      app  = "backend"
    }
  )
}

resource "aws_ecs_cluster" "main" {
  name = var.name

  capacity_providers = ["FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    local.tags,
    {
      Name = var.name
    }
  )
}

# module "task" {
#   source = "../modules/ecs/task"

#   name                  = var.name
#   cpu                   = 512
#   memory                = 1024
#   task_role_arn         = module.task_role.arn
#   container_definitions = <<EOF
#   [
#     {
#       "name": "${local.container_name}",
#       "image": "${var.image}",
#       "essential": true,
#       "cpu": 0,
#       "command": ["bundle", "exec", "puma"],
#       "logConfiguration": {
#         "logDriver": "awslogs",
#         "options": {
#           "awslogs-group": "${aws_cloudwatch_log_group.log-group.name}",
#           "awslogs-region": "${data.aws_region.current.name}",
#           "awslogs-stream-prefix": "ecs"
#         }
#       },
#       "environment": [
#         { "name": "DB_USERNAME", "value": "root" },
#       ],
#       "mountPoints": [],
#       "volumesFrom": [],
#       "portMappings": [
#         {
#           "containerPort": ${var.port},
#           "hostPort": ${var.port},
#           "protocol": "tcp"
#         }
#       ],
#       "stopTimeout": ${var.stop_timeout}
#     }
#   ]
#   EOF

#   tags = local.tags
# }

# module "service" {
#   source = "../modules/ecs/service"

#   service_discovery_registry_arn = aws_service_discovery_service.backend.arn
#   name                           = var.name
#   security_groups                = var.security_groups
#   cluster_id                     = var.cluster.id
#   subnet_ids                     = var.subnet_ids

#   container_name   = local.container_name
#   container_port   = var.port
#   target_group_arn = aws_lb_target_group.main.arn

#   task_definition_arn = module.task.arn

#   tags = local.tags
# }

# module "autoscaling" {
#   source = "../modules/ecs/headless-autoscaling-step-cpu"

#   name         = var.name
#   cluster_name = var.cluster.name
#   service_name = module.service.name
#   min_capacity = 1
#   max_capacity = 1
#   tags         = local.tags
# }