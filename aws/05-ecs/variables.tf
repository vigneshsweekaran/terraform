variable "name" {
  type        = string
  description = <<EOF
  Name prefix for resources.

  This can be deployment name or environment name.
  EOF
}

variable "tags" {
  type        = map(string)
  description = "common tags to apply to all resources"
}
