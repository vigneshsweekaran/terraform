locals {
  json_data = jsondecode(file("${path.module}/input.json"))
}

resource "aws_vpc" "main" {
  cidr_block                       = tostring(local.json_data.vpc_cidr)
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "vpc"])
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "igw"])
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = tostring(local.json_data.public_subnet1_cidr)
  availability_zone       = tostring(local.json_data.public_subnet1_availability_zone)
  map_public_ip_on_launch = true
  tags = {
    Name                                                                         = join("-", [tostring(local.json_data.cluster_name), "public", tostring(local.json_data.public_subnet1_availability_zone)])
    join("/", ["kubernetes.io/cluster", tostring(local.json_data.cluster_name)]) = "shared"
    "kubernetes.io/role/elb"                                                     = 1
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = tostring(local.json_data.public_subnet2_cidr)
  availability_zone       = tostring(local.json_data.public_subnet2_availability_zone)
  map_public_ip_on_launch = true
  tags = {
    Name                                                                         = join("-", [tostring(local.json_data.cluster_name), "public", tostring(local.json_data.public_subnet2_availability_zone)])
    join("/", ["kubernetes.io/cluster", tostring(local.json_data.cluster_name)]) = "shared"
    "kubernetes.io/role/elb"                                                     = 1
  }
}

resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = tostring(local.json_data.private_subnet1_cidr)
  availability_zone = tostring(local.json_data.private_subnet1_availability_zone)
  tags = {
    Name                                                                         = join("-", [tostring(local.json_data.cluster_name), "private", tostring(local.json_data.private_subnet1_availability_zone)])
    join("/", ["kubernetes.io/cluster", tostring(local.json_data.cluster_name)]) = "shared"
    "kubernetes.io/role/internal-elb"                                            = 1
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = tostring(local.json_data.private_subnet2_cidr)
  availability_zone = tostring(local.json_data.private_subnet2_availability_zone)
  tags = {
    Name                                                                         = join("-", [tostring(local.json_data.cluster_name), "private", tostring(local.json_data.private_subnet2_availability_zone)])
    join("/", ["kubernetes.io/cluster", tostring(local.json_data.cluster_name)]) = "shared"
    "kubernetes.io/role/internal-elb"                                            = 1
  }
}

resource "aws_eip" "nat" {
  depends_on = [aws_internet_gateway.main]
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "nat-gateway-eip"])
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "nat-gateway"])
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "public-route"])
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "private-route"])
  }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
