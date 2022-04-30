# This creates:
#
#  * a main VPC
#  * one private subnet per availability zone where our applications are housed
#  * one public subnet per availability zone for the load balancer

# AZs in the current region of the aws provider
data "aws_availability_zones" "current_availability_zones" {}
locals {
  azs = data.aws_availability_zones.current_availability_zones.names
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_network_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# we create one private and one public subnet per availability zone
# and use the minimum amount of address bits for subnets for this
#
locals {
  subnet_count                   = 2 * length(local.azs)
  additional_subnet_address_bits = ceil(log(local.subnet_count, 2))
}

resource "aws_subnet" "public" {
  count                   = length(local.azs)
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, local.additional_subnet_address_bits, count.index)
  availability_zone       = local.azs[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name} public ${count.index}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(local.azs)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, local.additional_subnet_address_bits, length(local.azs) + count.index)
  availability_zone = local.azs[count.index]
  vpc_id            = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name} private ${count.index}"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_route" "internet-access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table" "private" {
  count  = length(local.azs)
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name} ${count.index}"
    }
  )
}

resource "aws_route" "nat_access" {
  count                  = length(local.azs)
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Elastic IP
resource "aws_eip" "elastic_ip_for_nat_gw" {
  vpc = true
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_for_nat_gw.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}