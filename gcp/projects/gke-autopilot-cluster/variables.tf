variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the VPC network being created"
  type        = string
  default     = "gke-network"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "autopilot-cluster"
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  type        = string
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  type        = string
  default     = "ip-range-services"
}
