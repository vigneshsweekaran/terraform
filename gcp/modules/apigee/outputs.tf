output "org_id" {
  description = "Apigee Organization ID"
  value       = google_apigee_organization.org.id
}

output "instance_id" {
  description = "Apigee Instance ID"
  value       = google_apigee_instance.instance.id
}

output "service_attachment" {
  description = "Apigee Service Attachment for PSC"
  value       = google_apigee_instance.instance.service_attachment
}

output "environment_names" {
  description = "Map of Apigee Environment Names"
  value       = { for k, v in google_apigee_environment.environments : k => v.name }
}

output "envgroup_name" {
  description = "Apigee Environment Group Name"
  value       = google_apigee_envgroup.envgroup.name
}
