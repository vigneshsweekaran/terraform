terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider aws {
   region = "ap-south-1" 
}

resource "aws_vpc" "vpc_test" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_test"
  }
}

resource "aws_subnet" "subnet_public_1a" {
  vpc_id     = aws_vpc.vpc_test.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "subnet_public_1a_vpc_test"
  }
}

resource "aws_subnet" "subnet_public_1b" {
  vpc_id     = aws_vpc.vpc_test.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "subnet_public_1b_vpc_test"
  }
}

resource "aws_subnet" "subnet_private_1a" {
  vpc_id     = aws_vpc.vpc_test.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.1.3.0/24"

  tags = {
    Name = "subnet_private_1a_vpc_test"
  }
}

resource "aws_subnet" "subnet_private_1b" {
  vpc_id     = aws_vpc.vpc_test.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.1.4.0/24"

  tags = {
    Name = "subnet_private_1b_vpc_test"
  }
}