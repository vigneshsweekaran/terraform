variable "region" {
  description = "The Google Cloud region to deploy resources."
  type        = string
}

variable "service_name" {
  description = "The name of the Cloud Run service."
  type        = string
}

variable "image_name" {
  description = "The full path to the Docker image"
  type        = string
}

variable "deletion_protection" {
  description = "Cloud run service deletion protection"
  type        = bool
  default     = false
}

variable "service_account" {
  description = "Cloud run service account"
  type        = string
}

variable "cpu_limit" {
  description = "CPU limit for the container"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for the container"
  type        = string
  default     = "512Mi"
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
  default     = 10
}

variable "port" {
  description = "Port the container listens on"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "ingress" {
  description = "Ingress settings for the service"
  type        = string
  default     = "INGRESS_TRAFFIC_ALL"
  validation {
    condition = contains([
      "INGRESS_TRAFFIC_ALL",
      "INGRESS_TRAFFIC_INTERNAL_ONLY",
      "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
    ], var.ingress)
    error_message = "Ingress must be one of: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  }
}

variable "vpc_name" {
  description = "The name of the VPC network for Cloud Run Direct VPC egress."
  type        = string
}

variable "vpc_subnet_name" {
  description = "The name of the subnet for Cloud Run Direct VPC egress. Must be at least /26."
  type        = string
}

variable "vpc_egress_setting" {
  description = "Egress setting for Cloud Run Direct VPC egress (ALL_TRAFFIC or PRIVATE_RANGES_ONLY)."
  type        = string
  default     = "ALL_TRAFFIC"
  validation {
    condition     = contains(["ALL_TRAFFIC", "PRIVATE_RANGES_ONLY"], var.vpc_egress_setting)
    error_message = "vpc_egress_setting must be 'ALL_TRAFFIC' or 'PRIVATE_RANGES_ONLY'."
  }
}

# GCS Volume Mount Variables (optional)
variable "enable_gcs_volume" {
  description = "Enable GCS volume mount"
  type        = bool
  default     = false
}

variable "volume_name" {
  description = "Name of the volume"
  type        = string
  default     = ""
}

variable "mount_path" {
  description = "Mount path for the volume"
  type        = string
  default     = ""
}

variable "bucket_name" {
  description = "GCS bucket name for volume mount"
  type        = string
  default     = ""
}

variable "volume_read_only" {
  description = "Whether the volume mount is read-only"
  type        = bool
  default     = true
}

variable "allow_unauthenticated" {
  description = "Set to true to allow unauthenticated public access to the Cloud Run service."
  type        = bool
  default     = false # Default to false for security best practices
}
