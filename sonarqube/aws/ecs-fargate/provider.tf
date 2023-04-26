provider "aws" {
  region = var.aws_region
  #Not needed if aws-cli is configured
  # access_key = var.access_key
  # secret_key = var.secret_key
}
