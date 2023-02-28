variable "name" {
  description = "The name used for deployment, service and ingress resources"
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

variable "replica_count" {
  description = "The Replica count for deployment"
  type        = number
  default     = 1
}

variable "certificate_arn" {
  description = "Certificate arn"
  type        = string
}

variable "listen_ports" {
  description = "Listening ports Eg: '[{"HTTP": 80}, {"HTTPS":443}]'"
  type        = string
}

variable "ssl_redirect" {
  description = "SS redirect definition Eg: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'"
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