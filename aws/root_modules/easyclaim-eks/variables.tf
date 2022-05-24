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

variable "vpc_cidr" {
  description = "Vpc cidr"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet1_cidr" {
  description = "Public subnet1 cidr"
  type        = string
  default     = "192.168.0.0/18"
}

variable "public_subnet1_availability_zone" {
  description = "Public subnet1 availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "public_subnet2_cidr" {
  description = "Public subnet2 cidr"
  type        = string
  default     = "192.168.64.0/18"
}

variable "public_subnet2_availability_zone" {
  description = "Public subnet2 availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "private_subnet1_cidr" {
  description = "Private subnet1 cidr"
  type        = string
  default     = "192.168.128.0/18"
}

variable "private_subnet1_availability_zone" {
  description = "Private subnet1 availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "private_subnet2_cidr" {
  description = "Private subnet2 cidr"
  type        = string
  default     = "192.168.192.0/18"
}

variable "private_subnet2_availability_zone" {
  description = "Private subnet2 availability zone"
  type        = string
  default     = "us-east-1b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = ""
}

variable "node_autoscaling_min" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1
}

variable "node_autoscaling_desired" {
  description = "Desired node count for autoscaling"
  type        = number
  default     = 1
}

variable "node_autoscaling_max" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 2
}

variable "fp_namespaces" {
  description = "Namespaces to be watched by fargate profile"
  type        = list(string)
  default     = ["dev"]
}

variable "environment_name" {
  description = "Namespaces to be watched by fargate profile"
  type        = string
  default     = "dev"
}