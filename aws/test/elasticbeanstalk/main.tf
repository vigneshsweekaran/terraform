provider "aws" {
  region = "us-east-1"
}

locals {
  name = "demo"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_efs_file_system" "efs" {
}

data "aws_security_group" "instance" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["AWSEBSecurityGroup"]
  }

  depends_on = [
    aws_elastic_beanstalk_environment.beanstalkappenv
  ]
}

resource "aws_security_group" "efs" {
  description = "EFS Security Group"
  name_prefix = "efs-security-group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP ingress"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [
      data.aws_security_group.instance.id
    ]
  }
}

resource "aws_efs_mount_target" "efs_mount_targets_private" {
  for_each = toset(data.aws_subnets.default.ids)

  file_system_id  = aws_efs_file_system.efs.id
  security_groups = [aws_security_group.efs.id]
  subnet_id       = each.value
}

resource "aws_efs_access_point" "test" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 900
    uid = 900
  }
  root_directory {
    path = "/appdata"
    creation_info {
      owner_gid   = 900
      owner_uid   = 900
      permissions = 755
    }
  }
}

data "aws_iam_policy" "elasticbeanstallk_webtier" {
  name = "AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "ssmagent" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "instance" {
  name = "${local.name}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.elasticbeanstallk_webtier.arn, data.aws_iam_policy.ssmagent.arn]
}

resource "aws_iam_instance_profile" "instance" {
  name = "${local.name}-instance-profile"
  role = aws_iam_role.instance.name
}

resource "aws_elastic_beanstalk_application" "elasticbeanstalk_app" {
  name = "${local.name}-app"
}

resource "aws_elastic_beanstalk_environment" "beanstalkappenv" {
  name                = "${local.name}-env"
  application         = aws_elastic_beanstalk_application.elasticbeanstalk_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.1 running PHP 8.1"
  tier                = "WebServer"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.instance.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "True"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default.ids)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.medium"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 1
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
}
