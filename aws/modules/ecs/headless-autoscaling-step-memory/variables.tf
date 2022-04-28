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

variable "memory_high_threshold" {
  type        = string
  description = "MEMORY Utilization High Thresold"
  default     = 50
}

variable "memory_low_threshold" {
  type        = string
  description = "MEMORY Utilization Low Thresold"
  default     = 35
}

variable "scale_up_cooldown" {
  type        = number
  description = "the amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start"
  default     = 15
}

variable "scale_down_cooldown" {
  type        = number
  description = "the amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start"
  default     = 300
}
