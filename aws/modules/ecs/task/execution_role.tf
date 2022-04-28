# IAM role for the container agent to do things like
# pulling container images from ECR or writing container
# logs to somewhere.
#
# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
#
resource "aws_iam_role" "execution_role" {
  name               = "${var.name}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.execution_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "execution_role" {
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

resource "aws_iam_role_policy_attachment" "execution_role" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
