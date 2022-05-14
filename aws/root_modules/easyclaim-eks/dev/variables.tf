variable "region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}

variable "access_key" {
  description = "The aws access_key, not needed if aws-cli is congigured"
  type        = string
}

variable "secret_key" {
  description = "The aws secret_key, not needed if aws-cli is congigured"
  type        = string
}

variable "name" {
  description = "The name used for deployment, service and ingress resources"
  type        = string
}

variable "eks_cluster_name" {
  description = "The EKS cluster name"
  type        = string
}

variable "namespace" {
  description = "The Namespace name to deploy the application"
  type        = string
}

variable "image_name" {
  description = "The Docker image name"
  type        = string
}

variable "image_tag" {
  description = "The Docker image tag"
  type        = string
}

variable "target_port" {
  description = "The container target port"
  type        = number
}

variable "replica_count" {
  description = "The Replica count for deployment"
  type        = number
}

variable "certificate_arn" {
  description = "The arn of ACM certificate"
  type        = string
}

variable "healthcheck_path" {
  description = "ALB healthcheck path"
  type        = string
}

variable "healthcheck_port" {
  description = "ALB healthcheck port"
  type        = string
}

variable "api_url" {
  description = "Url of API"
  type        = string
}