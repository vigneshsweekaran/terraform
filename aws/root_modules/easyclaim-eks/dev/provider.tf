provider "aws" {
  region = var.region
  #Not needed if aws-cli is configured
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_eks_cluster" "default" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.default.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5.0"
    }
  }
}

terraform {
  backend "s3" {
    # Provide key and dynamodb_table as backend configuration
    # bucket = "terraform-bucket-demo"
    key    = "web-apps/admin-app/terraform.tfstate"
    # region = "us-east-1"
    # dynamodb_table = "terraform_state-dynamodb"
  }
}
