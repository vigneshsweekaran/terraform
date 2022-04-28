variable "name" {
  type        = string
  description = "name for resources"
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
  default     = {}
}

variable "policy" {
  type        = string
  description = "the policy document as json"
}
