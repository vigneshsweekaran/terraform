variable "name" {
  type        = string
  description = "name for resources"
}

variable "cluster_name" {
  type        = string
  description = "cluster name"
}

variable "service_name" {
  type        = string
  description = "name of the target service"
}

variable "tags" {
  type        = map(any)
  description = "tags to append to resources where applicable"
  default     = {}
}

variable "min_capacity" {
  type        = number
  description = "minimal number of instances"
  default     = 0
}

variable "max_capacity" {
  type        = number
  description = "maximum number of instances"
  default     = 0
}

variable "autoscaling_cooldown" {
  type        = number
  description = "the amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start"
  default     = 60
}
