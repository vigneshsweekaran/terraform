variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "AWS ECS Cluster Name"
  type        = string
}

variable "name" {
  description = "Application name"
  type        = string
  default     = "sonarqube"
}


variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
  default     = {}
}


variable "log_retention_days" {
  type        = number
  description = "log retention in days"
  default     = 30
}

variable "deletion_protection" {
  type        = bool
  description = "deletion protection setting for resources where applicable"
  default     = true
}

variable "stop_timeout" {
  type        = number
  description = "Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own."
  default     = 90
}
