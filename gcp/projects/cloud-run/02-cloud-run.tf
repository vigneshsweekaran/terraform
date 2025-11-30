# Cloud Run v2 service definition
resource "google_cloud_run_v2_service" "service" {
  name                  = var.service_name
  location              = var.region
  ingress               = "INGRESS_TRAFFIC_ALL"
  invoker_iam_disabled  = true

  template {
    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.repo.repository_id}/${var.image_name}:${var.image_tag}"
      
      ports {
        container_port = 8080
      }
    }
  }
}