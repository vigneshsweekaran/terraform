variable "region" {
  description = "The Google Cloud region to deploy resources."
  type        = string
}

variable "instance_name" {
  description = "The name of the Compute Engine instance."
  type        = string
}

variable "zone" {
  description = "The GCP zone for the instance (e.g., us-central1-a)."
  type        = string
}

variable "machine_type" {
  description = "The machine type for the instance (e.g., e2-micro)."
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_image" {
  description = "The boot disk image for the instance (e.g., debian-cloud/debian-11)."
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "boot_disk_size" {
  description = "The boot disk size in GB."
  type        = number
  default     = 20
}

variable "boot_disk_type" {
  description = "The boot disk type (e.g., pd-standard, pd-ssd)."
  type        = string
  default     = "pd-standard"
}

variable "network_name" {
  description = "The name of the VPC network to connect the instance to."
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork within the VPC to connect the instance to."
  type        = string
}

variable "assign_external_ip" {
  description = "Whether to assign a static external IP address to the instance."
  type        = bool
  default     = false
}

variable "can_ip_forward" {
  description = "Whether the instance can perform IP forwarding (required for VPN servers)."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "A startup script (user data) to run on the instance after creation."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A list of network tags for the instance."
  type        = list(string)
  default     = []
}