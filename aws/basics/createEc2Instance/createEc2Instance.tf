terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
}

provider "aws" {
    region = "ap-south-1"
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

