data "aws_iam_policy_document" "task_role" {
  version = "2012-10-17"

  statement {
    sid       = "allowElasitcacheAccess"
    effect    = "Allow"
    actions   = ["elasticache:*"]
    resources = ["*"]
  }
  statement {
    sid = "allowS3Access"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:CreateBucket"
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }
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
  source = "../../ecs/task_role"
  name   = "${var.name}-service-role"
  tags = merge(
    var.tags,
    {
      Name = "${var.name} service role"
    }
  )
  policy = data.aws_iam_policy_document.task_role.json
}
