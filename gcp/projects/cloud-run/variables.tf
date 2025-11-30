variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "GCP region (e.g., us-central1)"
  type        = string
  default     = "us-central1"
}

variable "repository_name" {
  description = "Artifact Registry repository ID"
  type        = string
  default     = "python-cloudrun-repo"
}

variable "service_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "python-service"
}

variable "image_name" {
  description = "Docker image name (without tag)"
  type        = string
  default     = "python-app"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "cloudbuild_sa_email" {
  description = "Service account email for Cloud Build (to push images). If you use Cloud Build, set this; otherwise leave empty."
  type        = string
  default     = ""
}
