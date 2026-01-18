# Cloud Run V2 Service
resource "google_cloud_run_v2_service" "backend" {
  name     = var.cloud_run_service
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"
  invoker_iam_disabled  = true
  deletion_protection   = false

  template {
    containers {
      image = var.cloud_run_image
      ports {
        container_port = 80
      }
    }
  }
}

# Serverless NEG for Cloud Run
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "cloudrun-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = google_cloud_run_v2_service.backend.name
  }
}

# Backend Service for Cloud Run
resource "google_compute_region_backend_service" "cloudrun_backend" {
  name                  = "cloudrun-backend"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"

  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
}

# URL Map for Cloud Run
resource "google_compute_region_url_map" "cloudrun_urlmap" {
  name            = "cloudrun-urlmap"
  region          = var.region
  default_service = google_compute_region_backend_service.cloudrun_backend.id
}

# Target HTTP Proxy for Cloud Run
resource "google_compute_region_target_http_proxy" "cloudrun_proxy" {
  name    = "cloudrun-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.cloudrun_urlmap.id
}

# Forwarding Rule for Cloud Run (Internal LB)
resource "google_compute_forwarding_rule" "cloudrun_forwarding_rule" {
  name                  = "cloudrun-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "INTERNAL_MANAGED"
  network               = google_compute_network.apigee_network.id
  subnetwork            = google_compute_subnetwork.main_subnet.id
  target                = google_compute_region_target_http_proxy.cloudrun_proxy.id
  port_range            = "80"
  ip_protocol           = "TCP"
  depends_on            = [google_compute_subnetwork.proxy_subnet]
}

# PSC Service Attachment for Cloud Run
resource "google_compute_service_attachment" "cloudrun_psc" {
  name        = "cloudrun-psc-attachment"
  region      = var.region
  description = "PSC Service Attachment for Cloud Run"

  enable_proxy_protocol    = false
  connection_preference    = "ACCEPT_AUTOMATIC"
  nat_subnets              = [google_compute_subnetwork.psc_subnet.id]
  target_service           = google_compute_forwarding_rule.cloudrun_forwarding_rule.id
}

# Apigee Endpoint Attachment (Southbound PSC)
resource "google_apigee_endpoint_attachment" "cloudrun_endpoint" {
  org_id             = google_apigee_organization.org.id
  endpoint_attachment_id = "apigee-to-cloudrun"
  location           = var.region
  service_attachment = google_compute_service_attachment.cloudrun_psc.id
}
