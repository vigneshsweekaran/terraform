# This creates:
#
#  * a main VPC
#  * one private subnet per availability zone where our applications are housed
#  * one public subnet per availability zone for the load balancer

# AZs in the current region of the aws provider
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values =  data.aws_vpc.default
  }

  tags = {
    Tier = "Private"
  }
}