output "id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "internet_gateway" {
  value = aws_internet_gateway.main
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}
