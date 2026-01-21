variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
}

# Apigee Variables
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

# Network Variables
variable "vpc_network_name" {
  description = "VPC Network Name"
  type        = string
  default     = "apigee-network"
}

variable "subnet_range" {
  description = "Subnet CIDR Range"
  type        = string
  default     = "10.0.0.0/24"
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

# Load Balancer Variables
variable "lb_name" {
  description = "Load Balancer Name"
  type        = string
  default     = "apigee-external-lb"
}

variable "enable_load_balancer" {
  description = "Enable or disable External Load Balancer creation"
  type        = bool
  default     = false
}
