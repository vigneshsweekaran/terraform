data "google_compute_network" "existing_vpc" {
  name    = "${var.project_name}-vpc"
}

data "google_compute_subnetwork" "existing_cloudrun_egress_subnet" {
  name    = "${var.project_name}-cloudrun-egress-subnet"
}

resource "google_service_account" "cloud_run_kong_sa" {
  project      = var.project_id
  account_id   = "${var.project_name}-cloud-run-kong-apig-sa"
  display_name = "Service Account for Cloud Run Kong Service"
}

resource "google_storage_bucket_iam_member" "bucket_reader_access" {
  bucket = var.gcs_bucket_name_for_kong_config
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_kong_sa.email}"
}

module "kong_cloud_run_service" {
  source  = "GoogleCloudPlatform/cloud-run/google//modules/v2"
  version = "~> 0.18"

  revision = "${var.project_name}-kong-apigateway-v8"

  project_id             = var.project_id
  location               = var.region
  service_name           = "${var.project_name}-kong-apigateway"
  create_service_account = false
  service_account        = google_service_account.cloud_run_kong_sa.email

  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  members = ["allUsers"]     #allAuthenticatedUsers/allUsers

  vpc_access = {
    egress = "PRIVATE_RANGES_ONLY"  #ALL_TRAFFIC/PRIVATE_RANGES_ONLY
    network_interfaces = {
      network    = "${var.project_name}-vpc"
      subnetwork = "${var.project_name}-cloudrun-egress-subnet"
    }
  }

  volumes = [
    {
      name = "kong-config-volume"
      gcs  = {
        bucket    = var.gcs_bucket_name_for_kong_config
        read_only = true
      }
    }
  ]

  containers = [
    {
      container_image = "us-central1-docker.pkg.dev/sodium-pattern-458507-i0/test/kong:3.9"
      container_name = "kong-apigateway"

      ports = {
        name           = "http1"
        container_port = "8000"
      }

      resources = {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }

      env_vars = { 
        KONG_DATABASE = "off"
        KONG_DECLARATIVE_CONFIG = "/opt/kong/declarative/kong.yaml"
      }

      volume_mounts = [
        {
          name = "kong-config-volume"
          mount_path = "/opt/kong/declarative"
        }
      ]
    }
  ]

  template_scaling = {
    min_instance_count = 1
    max_instance_count = 5
  }

  cloud_run_deletion_protection = false
}
