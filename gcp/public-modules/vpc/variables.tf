variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "project_name" {
  description = "The Project Name"
  type        = string
}

variable "region" {
  description = "The GCP region where subnets will be created."
  type        = string
}

variable "main_subnet_cidr_range" {
  description = "The CIDR range for the main subnet."
  type        = string
}

variable "cloudrun_egress_subnet_cidr_range" {
  description = "The CIDR range for the Cloud Run Direct VPC Egress subnet."
  type        = string
}