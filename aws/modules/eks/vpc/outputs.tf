output "vpc_id" {
  description = "VPC Id"
  value = aws_vpc.main.id
}

output "public_subnet1_id" {
  description = "Public subnet1 id"
  value = aws_subnet.public1.id
}

output "public_subnet2_id" {
  description = "Public subnet2 id"
  value = aws_subnet.public1.id
}

output "private_subnet1_id" {
  description = "Private subnet1 id"
  value = aws_subnet.private1.id
}

output "private_subnet2_id" {
  description = "Private subnet2 id"
  value = aws_subnet.private2.id
}