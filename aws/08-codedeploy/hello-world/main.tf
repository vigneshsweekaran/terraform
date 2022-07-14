data "aws_ami" "amazonlinux2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "hello-world" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.amazonlinux2.id

  tags = {
    Name        = "HelloWorld"
    Environment = "dev"
  }
}

resource "aws_iam_role" "hello-world" {
  name = "hello-world-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.hello-world.name
}

resource "aws_codedeploy_app" "hello-world" {
  name = "hello-world-app"
}

resource "aws_sns_topic" "hello-world" {
  name = "hello-world-topic"
}

resource "aws_codedeploy_deployment_group" "hello-world" {
  app_name              = aws_codedeploy_app.hello-world.name
  deployment_group_name = "hello-world-group"
  service_role_arn      = aws_iam_role.hello-world.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Environment"
      type  = "KEY_AND_VALUE"
      value = "dev"
    }
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "hello-world-trigger"
    trigger_target_arn = aws_sns_topic.hello-world.arn
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }
}