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

# 1. Create VPC
resource "aws_vpc" "vpc_dev" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_dev"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw_dev" {
  vpc_id = aws_vpc.vpc_dev.id

  tags = {
    "Name" = "igw_dev"
  }
}

# 3. Create custom public and private Router table
resource "aws_route_table" "rt_public_dev" {
  vpc_id = aws_vpc.vpc_dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_dev.id
  }

  tags = {
    "Name" = "rt_public_dev"
  }
}

resource "aws_route_table" "rt_private_dev" {
  vpc_id = aws_vpc.vpc_dev.id

  tags = {
    "Name" = "rt_private_dev"
  }
}

# 4. Create subnet
resource "aws_subnet" "subnet_public_1a_dev" {
  vpc_id     = aws_vpc.vpc_dev.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "subnet_public_1a_dev"
  }
}

resource "aws_subnet" "subnet_public_1b_dev" {
  vpc_id     = aws_vpc.vpc_dev.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "subnet_public_1b_dev"
  }
}

resource "aws_subnet" "subnet_private_1a_dev" {
  vpc_id     = aws_vpc.vpc_dev.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.1.3.0/24"

  tags = {
    Name = "subnet_private_1a_dev"
  }
}

resource "aws_subnet" "subnet_private_1b_dev" {
  vpc_id     = aws_vpc.vpc_dev.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.1.4.0/24"

  tags = {
    Name = "subnet_private_1b_dev"
  }
}

# 5.Associate subnet with Route table
resource "aws_route_table_association" "aws_route_table_association_public_1a_dev" {
  subnet_id      = aws_subnet.subnet_public_1a_dev.id
  route_table_id = aws_route_table.rt_public_dev.id
}

resource "aws_route_table_association" "aws_route_table_association_public_1b_dev" {
  subnet_id      = aws_subnet.subnet_public_1b_dev.id
  route_table_id = aws_route_table.rt_public_dev.id
}

resource "aws_route_table_association" "aws_route_table_association_private__1a_dev" {
  subnet_id      = aws_subnet.subnet_private_1a_dev.id
  route_table_id = aws_route_table.rt_private_dev.id
}

resource "aws_route_table_association" "aws_route_table_association_private__1b_dev" {
  subnet_id      = aws_subnet.subnet_private_1b_dev.id
  route_table_id = aws_route_table.rt_private_dev.id
}