# cloudrun-kong-service/variables.tf

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy the Cloud Run service."
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "The project_name"
  type        = string
}

variable "gcs_bucket_name_for_kong_config" {
  description = "The name of the GCS bucket containing kong.yaml."
  type        = string
}