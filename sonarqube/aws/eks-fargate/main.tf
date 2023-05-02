locals {
  cluster_name = "sonarqube"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "subnets_id" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_version = "1.24"
  cluster_name    = local.cluster_name
  cluster_endpoint_public_access = true
  vpc_id          = data.aws_vpc.default.id
  subnet_ids      = slice(data.aws_subnets.subnets_id.ids,4,6)

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }
  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false
}
