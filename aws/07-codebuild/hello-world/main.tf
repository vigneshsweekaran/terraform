data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "hello-world" {
  bucket_prefix = "codebuild-hello-world"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.hello-world.id
  acl    = "private"
}

resource "aws_ecr_repository" "hello-world" {
  name                 = "hello-world"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ssm_parameter" "hello-world" {
  name        = "/codeBuild/dockerPassword"
  description = "The Dockerhub password"
  type        = "SecureString"
  value       = var.dockerhub_password
}

resource "aws_iam_role" "hello-world" {
  name = "hello-world"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "hello-world" {
  role = aws_iam_role.hello-world.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.hello-world.arn}",
        "${aws_s3_bucket.hello-world.arn}/*"
      ]
    },
    {
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:PutImage",
        "ecr:UploadLayerPart"
      ],
      "Resource": "*",
      "Effect": "Allow"
    },
    {
      "Action" : [
        "ssm:GetParameters"
      ],
      "Resource" : "*",
      "Effect" : "Allow"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "hello-world" {
  name          = "hello-world"
  description   = "hell-world java app build project"
  build_timeout = "5"
  service_role  = aws_iam_role.hello-world.arn

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.hello-world.bucket
  }

  cache {
    type     = "S3"
    location = aws_s3_bucket.hello-world.bucket
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.hello-world.id}/build-log"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/vigneshsweekaran/hello-world.git"
    git_clone_depth = 1

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "master"

  tags = {
    Environment = "Test"
  }
}