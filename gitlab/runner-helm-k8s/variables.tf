variable "region" {
  default = "us-east-2"
}

variable "eks_cluster_name" {
  description = "AWS EKS cluster name"
  type        = string
}

variable "runner_registration_token" {
  description = "Gitlab runner registration Token"
  type        = string
}