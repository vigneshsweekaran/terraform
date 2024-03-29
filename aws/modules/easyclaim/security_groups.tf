resource "aws_security_group" "lb" {
  name   = "${var.name}-load-balancer"
  vpc_id = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_security_group" "frontend" {
  name   = "${var.name}-frontend"
  vpc_id = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.cidr_block]
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_security_group" "backend" {
  name   = "${var.name}-backend"
  vpc_id = module.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.cidr_block]
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}