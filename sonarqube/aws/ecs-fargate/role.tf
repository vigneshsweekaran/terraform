data "aws_iam_policy_document" "task_execution_role" {
  version = "2012-10-17"
  statement {
    sid    = "allowSSMAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["${aws_ssm_parameter.rds.arn}"]
  }

  statement {
    sid    = "allowCloutwatchAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "task_execution_role" {
  name               = "sonarqube"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = local.tags
}

data "aws_iam_policy_document" "assume" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "task_execution_role" {
  name   = "sonarqube-ssm-parameter"
  role   = aws_iam_role.task_execution_role.name
  policy = data.aws_iam_policy_document.task_execution_role.json
}
