variable "vpc_name" {
  description = "The name for the new custom VPC network."
  type        = string
}

variable "region" {
  description = "The GCP region where subnets will be created."
  type        = string
}

variable "main_subnet_cidr_range" {
  description = "The CIDR range for the main subnet in the specified region (e.g., 10.10.0.0/20)."
  type        = string
}

variable "create_cloudrun_egress_subnet" {
  description = "Whether to create a dedicated subnet for Cloud Run Direct VPC Egress (true/false)."
  type        = bool
  default     = false
}

variable "cloudrun_egress_subnet_cidr_range" {
  description = "The CIDR range for the Cloud Run Direct VPC Egress subnet. Only required if create_cloudrun_egress_subnet is true. Must be at least /26 (e.g., 10.10.16.0/26)."
  type        = string
  default     = null # Set a default of null if not created, can be overridden if created

  validation {
    # This validation only runs if the variable is set (i.e., not null)
    condition = var.create_cloudrun_egress_subnet ? (
      length(regexall("/(2[6-9]|[3][0-2])$", var.cloudrun_egress_subnet_cidr_range)) > 0
    ) : true
    error_message = "Cloud Run Direct VPC Egress subnet CIDR range must be at least /26 when created."
  }
}

variable "enable_private_ip_google_access" {
  description = "Whether to enable Private Google Access on the subnets."
  type        = bool
  default     = true
}