output "apigee_org_id" {
  description = "Apigee Organization ID"
  value       = google_apigee_organization.org.id
}

output "apigee_instance_id" {
  description = "Apigee Instance ID"
  value       = google_apigee_instance.instance.id
}

output "apigee_service_attachment" {
  description = "Apigee Service Attachment for PSC"
  value       = google_apigee_instance.instance.service_attachment
}

output "apigee_environment" {
  description = "Apigee Environment Name"
  value       = google_apigee_environment.environment.name
}

output "apigee_envgroup" {
  description = "Apigee Environment Group Name"
  value       = google_apigee_envgroup.envgroup.name
}

output "apigee_hostname" {
  description = "Apigee Hostname"
  value       = var.apigee_hostname
}

output "cloud_run_service_url" {
  description = "Cloud Run Service URL"
  value       = google_cloud_run_v2_service.backend.uri
}

output "cloudrun_psc_attachment" {
  description = "Cloud Run PSC Service Attachment"
  value       = google_compute_service_attachment.cloudrun_psc.id
}

output "endpoint_attachment_host" {
  description = "Apigee Endpoint Attachment Host"
  value       = google_apigee_endpoint_attachment.cloudrun_endpoint.host
}

output "load_balancer_ip" {
  description = "External Load Balancer IP Address"
  value       = google_compute_address.lb_ip.address
}

output "vpc_network" {
  description = "VPC Network Name"
  value       = google_compute_network.apigee_network.name
}

output "test_external_url" {
  description = "Test URL for external access"
  value       = "http://${google_compute_address.lb_ip.address}/cloudrun"
}
