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

variable "host" {
  description = "The FQDN for the service"
  type        = string
}

variable "alb_group_name" {
  description = "The ALB group name to bring all grouped ingress into single ALB"
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

variable "enable_hpa" {
  description = "Enable/Disable HPA"
  type        = bool
  default     = false
}

variable "hpa_min_replicas" {
  description = "The minimum replicas for HPA"
  type        = number
  default     = 1
}

variable "hpa_max_replicas" {
  description = "The maximum replicas for HPA"
  type        = number
  default     = 3
}

variable "enable_lb_soureip" {
  type        = bool
  default     = false
}

variable "ingress_annotations_sourceip" {
  description = "Additional ingress annotations for AWS lb sourceip"
  type = map(string)
}