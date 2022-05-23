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

variable "cluster_name" {
  description = "Eks cluster name"
  type        = string
}

variable "vpc_id" {
  description = "Vpc id"
  type        = string
}

variable "public_subnet1_id" {
  description = "Public subnet id 1"
  type        = string
}

variable "public_subnet2_id" {
  description = "Public subnet id 2"
  type        = string
}

variable "private_subnet1_id" {
  description = "Private subnet id 1"
  type        = string
}

variable "private_subnet2_id" {
  description = "Private subnet id 1"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "node_autoscaling_min" {
  description = "Minimum node count for autoscaling"
  type        = number
}

variable "node_autoscaling_desired" {
  description = "Desired node count for autoscaling"
  type        = number
}

variable "node_autoscaling_max" {
  description = "Maximum node count for autoscaling"
  type        = number
}

variable "eks_cluster_role" {
  description = "eks_cluster_role arn"
  type        = string
}

variable "eks_node_group_role" {
  description = "eks_node_group_role arn"
  type        = string
}

variable "fargate_pod_execution_role" {
  description = "fargate_pod_execution_role arn"
  type        = string
}

variable "fp_namespaces" {
  description = "Namespaces to be watched by fargate profile"
  type        = list(string)
}

variable "environment_name" {
  description = "Namespaces to be watched by fargate profile"
  type        = string
  default     = "dev"
}