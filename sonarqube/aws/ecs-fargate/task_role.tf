data "aws_iam_policy_document" "task_role" {
  version = "2012-10-17"
  statement {
    sid    = "allowSSMAccess"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}
module "task_role" {
  source = "../../../aws/modules/ecs/task_role"
  name   = "${var.name}-service-role"
  tags = merge(
    var.tags,
    {
      Name = "${var.name} service role"
    }
  )
  policy = data.aws_iam_policy_document.task_role.json
}

