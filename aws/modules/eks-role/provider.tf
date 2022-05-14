provider "aws" {
  region = var.region
  #Not needed if aws-cli is configured
  access_key = var.access_key
  secret_key = var.secret_key
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.21"
    }
  }
}

terraform {
  backend "s3" {
    # Provide key and dynamodb_table as backend configuration
    # bucket = "terraform-bucket-demo"
    # key    = "eks-cluster1/terraform.tfstate"
    # region = "us-east-1"
    # dynamodb_table = "terraform_state-dynamodb"
  }
}
