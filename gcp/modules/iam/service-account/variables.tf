variable "service_account_id" {
  description = "The ID of the service account to create. Must be unique within the project. Max 30 characters, must be lowercase and contain only alphanumeric characters or dashes."
  type        = string
}

variable "service_account_display_name" {
  description = "A user-friendly name for the service account."
  type        = string
  default     = "Service Account for GCS Bucket Reader"
}

variable "service_account_description" {
  description = "A description for the service account."
  type        = string
  default     = "Service account with read access to a specific GCS bucket."
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket to grant read access to."
  type        = string
}