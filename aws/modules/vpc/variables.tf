variable "name" {
  type        = string
  description = <<EOF
  Name prefix for resources.

  This can e.g. be a deployment name or environment or however you want to call things.
  EOF
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
  default     = {}
}

variable "vpc_network_cidr" {
  type        = string
  description = "the main vpc network address in CIDR notation."

  # This comes from the RFC 1918 10.0.0.0/8
  # private network block.
  #
  # The 10.0.0.0/16 address gives us one
  # byte worth of potential vpc addresses
  # out of the same block that can be
  # connected.
  #
  default = "10.0.0.0/16"
}

