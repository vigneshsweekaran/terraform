# Kubernetes cluster connection details from config file

provider "aws" {
  region = var.region
  access_key = var.cache_bucket_access_key
  secret_key = var.cache_bucket_secret_key
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# EKS cluster connection details from state file
# provider "helm" {
#   kubernetes {
#     host                   = data.aws_eks_cluster.cluster.endpoint
#     cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
#     exec {
#       api_version = "client.authentication.k8s.io/v1alpha1"
#       args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
#       command     = "aws"
#     }
#   }
# }

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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3.0"
    }
  }
}

terraform {
 backend "s3" {
    # Provide s3 bucket name, key and dynamodb table name as backend configuration
    # bucket = "gitlab-runner-bucket"
    # key    = "gitlab-runner-1/terraform.tfstate"
    # region = "us-west-2"
    # dynamodb_table = "terraform_state-gitlab-runner"
  }
}
