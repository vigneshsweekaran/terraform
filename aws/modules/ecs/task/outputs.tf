output "arn" {
  description = "ARN of the generated task definition"
  value       = aws_ecs_task_definition.main.arn
}
