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
resource "aws_vpc" "vpc_apache2" {
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_apache2"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "igw_apache2" {
  vpc_id = aws_vpc.vpc_apache2.id

  tags = {
    "Name" = "igw_apache2"
  }
}

# 3. Create custom Router table
resource "aws_route_table" "rt_public_apache2" {
  vpc_id = aws_vpc.vpc_apache2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_apache2.id
  }

  tags = {
    "Name" = "rt_public_apache2"
  }
}

# 4. Create Subnet
resource "aws_subnet" "subnet_public_1a_apache2" {
  vpc_id     = aws_vpc.vpc_apache2.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.2.1.0/24"

  tags = {
    Name = "subnet_public_1a_apache2"
  }
}

# 5.Associate subnet with Route table
resource "aws_route_table_association" "aws_route_table_association_apache2" {
  subnet_id      = aws_subnet.subnet_public_1a_apache2.id
  route_table_id = aws_route_table.rt_public_apache2.id
}

# 6. Create security Group to allow port 22, 80, 443
resource "aws_security_group" "sg_apache2" {
  name        = "sg_apache2"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc_apache2.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_apache2"
  }
}

# 7. Create a network interface with the ip in the subnet created in step 4
resource "aws_network_interface" "ni_apache2" {
  subnet_id       = aws_subnet.subnet_public_1a_apache2.id
  private_ips     = ["10.2.1.50"]
  security_groups = [aws_security_group.sg_apache2.id]

  tags = {
    "Name" = "ni_apache2"
  }
}

# 8. Assign elastic ip to the interface created in step 7
resource "aws_eip" "eip_apache2" {
  vpc                       = true
  network_interface         = aws_network_interface.ni_apache2.id
  associate_with_private_ip = "10.2.1.50"

  depends_on = [aws_internet_gateway.igw_apache2]

  tags = {
    "Name" = "eip_apache2"
  }
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "ubuntu" {
    ami = "ami-0db0b3ab7df22e366"
    instance_type = "t2.micro"
    availability_zone = "ap-south-1a"
    key_name = "venkatesh"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.ni_apache2.id
    }
    
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo My first terraform script > /var/www/html/index.html'
                EOF
    tags = {
        Name = "Ubuntu_apache2"
        Provider = "terraform"
    } 
}