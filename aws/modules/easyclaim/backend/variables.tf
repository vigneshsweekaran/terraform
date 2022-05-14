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

variable "cluster" {
  description = "aws ecs cluster"
}

variable "image" {
  type        = string
  description = "full qualified image name of the backend docker image with tag"
}

variable "deletion_protection" {
  type        = bool
  description = "enable deletion protection setting for applicable resources"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "id of the main vpc"
}

variable "security_groups" {
  type        = list(string)
  description = "list of security groups this service should be part of"
}

variable "subnet_ids" {
  type        = list(string)
  description = "private subnets for this deployment"
}

variable "load_balancer_security_group_id" {
  type        = string
  description = "ID of the load balancer security group"
}

variable "port" {
  type        = number
  description = "port number of the exposed container"
  default     = 80
}

variable "path_prefix" {
  type        = string
  description = "url path prefix"
  default     = ""
}

variable "listener_arn" {
  type        = string
  description = "arn of the load balancer listener"
}

variable "log_retention_days" {
  type        = number
  description = "log retention in days"
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
  default     = {}
}

variable "deployment_prefix" {
  type        = string
  description = "something like dev-elearnio-net"
}

variable "stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own."
  default     = 90
}

variable "desired_count" {
  type        = number
  description = "Desired count for ecs service instances. This is only the initial count and defaults to ECSs default of 0."
  default     = 3
}

variable "enable_backend_autoscaling" {
  type        = bool
  description = "Enable/disable autoscaling for backend service"
  default     = false
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