variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS K8s version"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "AWS vpc id"
  type        = string
  default     = null
}

variable "subnet_ids" {
    description = "VPC subnet ids"
    type        = list(string)
    default     = []
}