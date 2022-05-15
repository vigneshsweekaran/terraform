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
  default = ""
}

variable "public_subnet1_id" {
  description = "Public subnet id 1"
  type        = string
  default = ""
}

variable "public_subnet2_id" {
  description = "Public subnet id 2"
  type        = string
  default = ""
}

variable "private_subnet1_id" {
  description = "Private subnet id 1"
  type        = string
  default = ""
}

variable "private_subnet2_id" {
  description = "Private subnet id 1"
  type        = string
  default = ""
}

variable "filter_tags" {
  description = "Map of tags used to filter and get the vpc id and subnet id's"
  type = map(string)

  default = {
    Name = ""
  }
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

variable "fp_namespaces" {
  description = "Namespaces to be watched by fargate profile"
  type        = list(string)
}

variable "environment_name" {
  description = "Namespaces to be watched by fargate profile"
  type        = string
  default     = "dev"
}