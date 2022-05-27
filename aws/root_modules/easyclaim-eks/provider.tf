provider "aws" {
  region = var.region
  #Not needed if aws-cli is configured
  # access_key = var.access_key
  # secret_key = var.secret_key
}

# terraform {
#   backend "s3" {
#     key = "eks/easyclaim/terraform.tfstate"
#   }
# }

data "aws_eks_cluster" "default" {
  name = var.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name

  depends_on = [
    module.eks
  ]
}

provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

