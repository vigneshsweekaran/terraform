resource "aws_lb" "main" {
  name                       = var.name
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = var.deletion_protection
  security_groups            = var.security_groups
  subnets                    = var.subnet_ids
  depends_on                 = [var.internet_gateway]
  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
