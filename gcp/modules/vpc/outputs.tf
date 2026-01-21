# modules/vpc-network/outputs.tf

output "vpc_id" {
  description = "The self_link of the created VPC network."
  value       = google_compute_network.custom_vpc.id
}

output "vpc_name" {
  description = "The name of the created VPC network."
  value       = google_compute_network.custom_vpc.name
}

output "main_subnet_id" {
  description = "The self_link of the main subnet."
  value       = google_compute_subnetwork.main_subnet.id
}

output "main_subnet_name" {
  description = "The name of the main subnet."
  value       = google_compute_subnetwork.main_subnet.name
}

output "main_subnet_region" {
  description = "The region of the main subnet."
  value       = google_compute_subnetwork.main_subnet.region
}

# Conditional output for cloudrun_egress_subnet
output "cloudrun_egress_subnet_id" {
  description = "The self_link of the Cloud Run egress subnet (null if not created)."
  value       = var.create_cloudrun_egress_subnet ? google_compute_subnetwork.cloudrun_egress_subnet[0].id : null
}

output "cloudrun_egress_subnet_name" {
  description = "The name of the Cloud Run egress subnet (null if not created)."
  value       = var.create_cloudrun_egress_subnet ? google_compute_subnetwork.cloudrun_egress_subnet[0].name : null
}

output "cloudrun_egress_subnet_region" {
  description = "The region of the Cloud Run egress subnet (null if not created)."
  value       = var.create_cloudrun_egress_subnet ? google_compute_subnetwork.cloudrun_egress_subnet[0].region : null
}

output "psc_subnet_id" {
  description = "ID of the PSC subnet."
  value       = var.enable_psc_subnet ? google_compute_subnetwork.psc_subnet[0].id : null
}

output "proxy_subnet_id" {
  description = "ID of the Proxy subnet."
  value       = var.enable_proxy_subnet ? google_compute_subnetwork.proxy_subnet[0].id : null
}