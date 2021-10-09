# Kubernetes cluster connection details from config file
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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3.0"
    }
  }
}

# terraform {
#   backend "s3" {
#     #Provide key and dynamodb_table as backend configuration
#     bucket = "terraform_state-eks"
#     #key    = "gitlab-runner/terraform.tfstate"
#     region = "us-west-2"
#     #dynamodb_table = "terraform_state-eks"
#   }
# }
