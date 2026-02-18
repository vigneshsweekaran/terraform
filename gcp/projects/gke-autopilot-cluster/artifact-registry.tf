resource "google_artifact_registry_repository" "docker_hub_remote" {
  location      = var.region
  repository_id = "docker-hub-remote"
  description   = "Docker Hub Remote Repository"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "Docker Hub"
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}
