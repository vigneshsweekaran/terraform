variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "lb_name" {
  description = "Load Balancer Name"
  type        = string
  default     = "apigee-external-lb"
}

variable "apigee_service_attachment" {
  description = "Apigee Instance Service Attachment URI"
  type        = string
}

variable "network_id" {
  description = "VPC Network ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for PSC NEG"
  type        = string
}

variable "enable_load_balancer" {
  description = "Enable or disable External Load Balancer creation"
  type        = bool
  default     = true
}
