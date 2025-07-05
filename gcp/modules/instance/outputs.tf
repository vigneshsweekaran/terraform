# modules/gce-instance/outputs.tf

output "instance_id" {
  description = "The self_link of the created Compute Engine instance."
  value       = google_compute_instance.default.id
}

output "instance_name" {
  description = "The name of the created Compute Engine instance."
  value       = google_compute_instance.default.name
}

output "external_ip_address" {
  description = "The external IP address of the instance (null if not assigned)."
  value       = var.assign_external_ip ? google_compute_address.external_ip[0].address : null
}

output "internal_ip_address" {
  description = "The internal IP address of the instance."
  value       = google_compute_instance.default.network_interface[0].network_ip
}