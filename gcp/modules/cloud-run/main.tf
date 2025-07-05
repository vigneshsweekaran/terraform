resource "google_cloud_run_v2_service" "default" {
  name     = var.service_name
  location = var.region
  
  deletion_protection = var.deletion_protection
  ingress             = var.ingress

  template {
    service_account = var.service_account

    vpc_access {
      network_interfaces {
        network     = var.vpc_name
        subnetwork  = var.vpc_subnet_name
      }
  
      egress  = var.vpc_egress_setting
    }

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.image_name
      
      ports {
        container_port = var.port
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      # Environment variables
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      # Optional GCS volume mount
      dynamic "volume_mounts" {
        for_each = var.enable_gcs_volume ? [1] : []
        content {
          name       = var.volume_name
          mount_path = var.mount_path
        }
      }
    }

    # Optional GCS volume
    dynamic "volumes" {
      for_each = var.enable_gcs_volume ? [1] : []
      content {
        name = var.volume_name
        gcs {
          bucket    = var.bucket_name
          read_only = var.volume_read_only
        }
      }
    }
  }
}

# IAM Policy to allow unauthenticated access if 'allow_unauthenticated' is true
resource "google_cloud_run_v2_service_iam_member" "invoker_public_access" {
  # Use 'count' to conditionally create this resource
  count = var.allow_unauthenticated ? 1 : 0

  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers" # This special identifier grants access to anyone on the internet
}
