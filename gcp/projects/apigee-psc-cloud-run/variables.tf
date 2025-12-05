variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-east1-a"
}

variable "apigee_env" {
  description = "Apigee Environment Name"
  type        = string
  default     = "eval"
}

variable "apigee_envgroup" {
  description = "Apigee Environment Group Name"
  type        = string
  default     = "eval-group"
}

variable "apigee_hostname" {
  description = "Apigee Hostname"
  type        = string
  default     = "api.example.com"
}

variable "vpc_network_name" {
  description = "VPC Network Name"
  type        = string
  default     = "apigee-network"
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "apigee-subnet"
}

variable "subnet_range" {
  description = "Subnet CIDR Range"
  type        = string
  default     = "10.0.0.0/24"
}

variable "psc_subnet_name" {
  description = "PSC Subnet Name"
  type        = string
  default     = "psc-subnet"
}

variable "psc_subnet_range" {
  description = "PSC Subnet CIDR Range"
  type        = string
  default     = "10.1.0.0/24"
}

variable "proxy_subnet_name" {
  description = "Proxy Subnet Name"
  type        = string
  default     = "proxy-subnet"
}

variable "proxy_subnet_range" {
  description = "Proxy Subnet CIDR Range"
  type        = string
  default     = "10.2.0.0/24"
}

variable "cloud_run_service" {
  description = "Cloud Run Service Name"
  type        = string
  default     = "backend-service"
}

variable "cloud_run_image" {
  description = "Cloud Run Container Image"
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "lb_name" {
  description = "Load Balancer Name"
  type        = string
  default     = "apigee-external-lb"
}
