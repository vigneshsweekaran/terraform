output "cluster_name" {
  description = "Cluster name"
  value       = module.gke.cluster_name
}

output "cluster_region" {
  description = "Cluster region"
  value       = var.region
}

output "bastion_name" {
  description = "Name of the bastion host"
  value       = google_compute_instance.bastion.name
}

output "get_credentials_command" {
  description = "Command to get credentials"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

output "artifact_registry_repo" {
  description = "Artifact Registry Repository ID"
  value       = google_artifact_registry_repository.docker_hub_remote.name
}
