locals {
  name = "sonarqube"
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = local.name
  cidr = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.available.names,1,3)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_version = "1.24"
  cluster_name    = local.name
  cluster_endpoint_public_access = true
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
    }
  }

  # Fargate Profile(s)
  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "default"
        }
      ]
    }
    sonarqube = {
      name = "sonarqube"
      selectors = [
        {
          namespace = "sonarqube"
        }
      ]
    }

  }

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false
}
