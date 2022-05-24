terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
    kubernetes = {
      version = "~> 2.11.0"
    }
    local = {
      version = "~> 1.4"
    }
    template = {
      version = "~> 2.1"
    }
    external = {
      version = "~> 1.2"
    }
  }
}
