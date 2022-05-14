locals {
  tags = {
    "billing-group" = var.name
  }
  deployment_prefix = "dev"
}

module "vpc" {
  source = "../vpc"
  providers = {
    aws         = aws
  }

  name = var.name
  tags = local.tags
}

# module "vpc" {
#   source = "../vpc_default"
# }

data "aws_region" "region" {}

module "load_balancer" {
  providers = {
    aws         = aws
  }

  source              = "../alb"
  name                = var.name
  tags                = local.tags
  security_groups     = [aws_security_group.lb.id]
  subnet_ids          = module.vpc.public_subnet_ids
  internet_gateway    = module.vpc.internet_gateway
  deletion_protection = var.deletion_protection
}

resource "aws_ecs_cluster" "main" {
  name = var.name
  capacity_providers = ["FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    local.tags,
    {
      Name = var.name
    }
  )
}

module "frontend" {
  source = "./frontend"
  providers = {
    aws         = aws
  }

  name                            = "${var.name}-frontend"
  name_env                        = var.name_env
  cluster                         = aws_ecs_cluster.main
  vpc_id                          = module.vpc.id
  security_groups                 = [aws_security_group.frontend.id]
  subnet_ids                      = module.vpc.private_subnet_ids
  image                           = var.frontend_image
  deletion_protection             = var.deletion_protection
  listener_arn                    = module.load_balancer.listener_arn
  log_retention_days              = var.log_retention_days
  tags                            = var.tags
  load_balancer_security_group_id = aws_security_group.lb.id
  deployment_prefix               = local.deployment_prefix
  enable_frontend_autoscaling     = var.enable_frontend_autoscaling
  frontend_min_capacity           = var.frontend_min_capacity
  frontend_max_capacity           = var.frontend_max_capacity
}

module "backend" {
  source = "./backend"
  providers = {
    aws         = aws
  }

  name                             = "${var.name}-backend"
  name_env                         = var.name_env
  cluster                          = aws_ecs_cluster.main
  vpc_id                           = module.vpc.id
  security_groups                  = [aws_security_group.backend.id]
  subnet_ids                       = module.vpc.private_subnet_ids
  image                            = var.backend_image
  deletion_protection              = var.deletion_protection
  listener_arn                     = module.load_balancer.listener_arn
  log_retention_days               = var.log_retention_days
  tags                             = var.tags
  load_balancer_security_group_id  = aws_security_group.lb.id
  deployment_prefix                = local.deployment_prefix
  enable_backend_autoscaling       = var.enable_backend_autoscaling
  backend_min_capacity             = var.backend_min_capacity
  backend_max_capacity             = var.backend_max_capacity
}
