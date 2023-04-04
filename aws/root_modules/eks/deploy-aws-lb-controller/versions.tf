terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45.0"
    }
    kubernetes = {
      version = "~> 2.16.1"
    }
    helm = {
      version = "~> 2.7.1"
    }
  }
}