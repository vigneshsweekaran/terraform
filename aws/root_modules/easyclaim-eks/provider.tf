provider "aws" {
  region = var.region
  #Not needed if aws-cli is configured
  # access_key = var.access_key
  # secret_key = var.secret_key
}

# data "aws_eks_cluster" "default" {
#   name = var.eks_cluster_name
# }

# data "aws_eks_cluster_auth" "default" {
#   name = var.eks_cluster_name
# }

# provider "kubernetes" {
#   host                   = data.aws_eks_cluster.default.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.default.token
# }

# terraform {
#   backend "s3" {
#     key = "eks/easyclaim/terraform.tfstate"
#   }
# }
