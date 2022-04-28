resource "aws_ecs_service" "main" {
  name            = var.name
  task_definition = var.task_definition_arn
  cluster         = var.cluster_id

  desired_count = var.desired_count

  # TODO change after evaluation
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  # ignore changes to `desired_count` as this will be
  # changed by auto-scaling policies
  #
  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  service_registries {
    registry_arn = var.service_discovery_registry_arn
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  tags = var.tags
}
