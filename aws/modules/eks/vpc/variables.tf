variable "region" {
  description = "The aws region"
  type        = string
  default     = "us-east-1"
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

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "eks-cluster"
}
