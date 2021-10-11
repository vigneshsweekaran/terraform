variable "region" {
  default = "us-east-2"
}

variable "cache_bucket_access_key" {
  description = "The aws access_key"
  type        = string
}

variable "cache_bucket_secret_key" {
  description = "The aws secret_key"
  type        = string
}

variable "cache_bucket_name" {
  description = "AWS S3 bucket name for Gitlab runner cache"
  type        = string
}

variable "eks_cluster_name" {
  description = "AWS EKS cluster name"
  type        = string
}

variable "runner_registration_token" {
  description = "Gitlab runner registration Token"
  type        = string
}