# Artifact Registry repository to store the Docker image
resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.repository_name
  format        = "DOCKER"
  description   = "Repository for Python Cloud Run images"
}
