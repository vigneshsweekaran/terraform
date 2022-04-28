resource "aws_ecs_task_definition" "main" {
  family                = var.name
  container_definitions = var.container_definitions

  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = var.task_role_arn

  requires_compatibilities = ["FARGATE"]

  # `network_mode` determines how containers of a task talk to
  # each other.
  # `awsvpc` is the only supported settings for fargate tasks.
  #
  network_mode = "awsvpc"

  # `cpu` and `memory` are required for fargate.
  cpu    = var.cpu
  memory = var.memory
  ephemeral_storage {
    size_in_gib = var.ephemeral_storage_size
  }

  tags = var.tags
}
