terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    # backend "s3" {
    #     bucket = "terraform-vignesh-test123"
    #     dynamodb_table = "terraform-vignesh-test123"
    #     key    = "dev/terraform.tfstate"
    #     region = "us-west-2"
    #     access_key = ""
    #     secret_key = ""
    # }
}

variable "aws_region" {
  description = "AWS region"
  default = "us-west-2"
  type = string
}

provider "aws" {
    region = var.aws_region
    access_key = ""
    secret_key = ""
}

resource "aws_instance" "ubuntu" {
    ami = "ami-0ee8244746ec5d6d4"
    instance_type = "t2.micro"

    tags = {
        Name = "vignesh"
        Provider = "terraform"
    } 
}

output "ec2_instance_public_ip" {
    value = aws_instance.ubuntu.public_ip
}
