resource "aws_ecs_service" "main" {
  name            = var.name
  task_definition = var.task_definition_arn
  cluster         = var.cluster_id
  launch_type     = "FARGATE"

  # ignore changes to `desired_count` as this will be
  # changed by auto-scaling policies
  #
  lifecycle {
    ignore_changes = [desired_count]
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_groups
    assign_public_ip = var.assign_public_ip
  }

  enable_ecs_managed_tags = true
  propagate_tags          = "TASK_DEFINITION"

  tags = var.tags
}
