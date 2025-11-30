output "cloud_run_service_url" {
  description = "URL of the deployed Cloud Run service"
  value       = google_cloud_run_v2_service.service.uri
}

output "artifact_registry_repository" {
  description = "Full name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.repo.name
}

output "artifact_registry_location" {
  description = "Full Docker image path for pushing images"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}"
}
