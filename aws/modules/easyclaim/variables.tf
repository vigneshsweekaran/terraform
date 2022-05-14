variable "name" {
  type        = string
  description = <<EOF
  Name prefix for resources.

  This can e.g. be a deployment name or environment or however you want to call things.
  EOF
}

variable "name_env" {
  type        = string
  description = <<EOF
  Name Environment for resources.

  This can e.g. be a deployment name or environment or however you want to call things.
  EOF
}

variable "log_retention_days" {
  type        = number
  description = "log retention in days"
}

variable "deletion_protection" {
  type        = bool
  description = "deletion protection setting for resources where applicable"
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
}

variable "frontend_image" {
  type        = string
  description = "full qualified image name of the docker image with tag"
}

variable "backend_image" {
  type        = string
  description = "full qualified image name of the docker image with tag"
}

variable "worker_desired_count" {
  type        = number
  description = "Desired count for ecs service instances. This is only the initial count and defaults to ECSs default of 0."
  default     = 3
}

variable "enable_frontend_autoscaling" {
  type        = bool
  description = "Enable/disable ecs service autoscaling "
  default     = false
}

variable "enable_backend_autoscaling" {
  type        = bool
  description = "Enable/disable ecs service autoscaling "
  default     = false
}

variable "frontend_min_capacity" {
  type        = number
  description = "Minimum capacity for autoscaling"
  default     = 1
}

variable "frontend_max_capacity" {
  type        = number
  description = "Maximum capacity for autoscaling"
  default     = 3
}

variable "backend_min_capacity" {
  type        = number
  description = "Minimum capacity for autoscaling"
  default     = 1
}

variable "backend_max_capacity" {
  type        = number
  description = "Maximum capacity for autoscaling"
  default     = 3
}