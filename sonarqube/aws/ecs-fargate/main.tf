locals {
  container_image = "sonarqube:9.9.0-community"
  container_name  = "sonarqube"
  container_port  = "8080"
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
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

# Task definition
resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "sonarqube"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "sonarqube",
    "image": "sonarqube:9.9.0-community",
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "environment": [
      {"name": "SONAR_JDBC_URL", "value": "https://postgres.com"},
      {"name": "SONAR_JDBC_USERNAME", "value": "postgres"},
      {"name": "SONAR_JDBC_PASSWORD", "value": "password"}
    ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

# ECS Service

