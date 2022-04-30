variable "name" {
  type        = string
  description = <<EOF
  Name prefix for resources.

  This can e.g. be a deployment name or environment or however you want to call things.
  EOF
}

variable "internet_gateway" {
  description = "internet gateway to depend on"
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
  default     = {}
}

variable "security_groups" {
  type        = list(string)
  description = "list of security group ids the lb should belong to"
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of subnets of the load balancer"
}


variable "deletion_protection" {
  type        = bool
  description = "deletion protection setting for the main lb"
  default     = true
}
