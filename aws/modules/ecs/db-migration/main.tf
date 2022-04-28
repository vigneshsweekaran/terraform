data "aws_caller_identity" "caller" {}

resource "null_resource" "main" {
  provisioner "local-exec" {
    # we dont use db:prepare as it runs db:create -> db:seed -> db:migrate
    command = <<EOF
      STS=$(aws sts assume-role --role-arn "arn:aws:iam::${data.aws_caller_identity.caller.account_id}:role/terraform" --role-session-name "db-migration" --output text)
      export AWS_ACCESS_KEY_ID=$(echo $STS | cut -d ' ' -f 5)
      export AWS_SECRET_ACCESS_KEY=$(echo $STS |  cut -d ' ' -f 7)
      export AWS_SESSION_TOKEN=$(echo $STS | cut -d ' ' -f 8)
      aws ecs run-task \
        --cluster ${var.cluster_name} \
        --network-configuration '{"awsvpcConfiguration": {"subnets": ${jsonencode(var.subnet_ids)}, "securityGroups": ${jsonencode(var.security_group_ids)}, "assignPublicIp": "DISABLED"}}' \
        --task-definition ${var.task_definition_arn} \
        --overrides '{"containerOverrides": [{ "name": "${var.container_name}", "command": ["bundle", "exec", "rake", "db:create", "db:migrate", "db:seed"]}]}' \
        --launch-type FARGATE
    EOF
  }

  triggers = {
    task_definition_arn = var.task_definition_arn
  }
}
