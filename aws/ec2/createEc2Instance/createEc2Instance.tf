terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

variable "aws_region" {
  description = "AWS region"
  #default = ap-south-1
  type = string
}

provider "aws" {
    region = var.aws_region
    profile = "terraform"
}

resource "aws_instance" "ubuntu" {
    ami = "ami-0db0b3ab7df22e366"
    instance_type = "t2.micro"
    key_name = "venkatesh"

    tags = {
        Name = "Ubuntu"
        Provider = "terraform"
    } 
}

output "ec2_instance_public_ip" {
    value = aws_instance.ubuntu.public_ip
}
