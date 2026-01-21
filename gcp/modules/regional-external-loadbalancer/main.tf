terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0"
    }
  }
}

# Reserve Regional External IP Address
resource "google_compute_address" "lb_ip" {
  count  = var.enable_load_balancer ? 1 : 0
  name   = "${var.lb_name}-ip"
  region = var.region
}

# PSC Network Endpoint Group for Apigee
resource "google_compute_region_network_endpoint_group" "apigee_psc_neg" {
  count                 = var.enable_load_balancer ? 1 : 0
  name                  = "apigee-psc-neg"
  region                = var.region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  psc_target_service = var.apigee_service_attachment
  network            = var.network_id
  subnetwork         = var.subnet_id
}

# Regional Backend Service for External LB
resource "google_compute_region_backend_service" "apigee_backend" {
  count                 = var.enable_load_balancer ? 1 : 0
  name                  = "apigee-backend"
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"

  backend {
    group           = google_compute_region_network_endpoint_group.apigee_psc_neg[0].id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL Map for External LB
resource "google_compute_region_url_map" "lb_urlmap" {
  count           = var.enable_load_balancer ? 1 : 0
  name            = "${var.lb_name}-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.apigee_backend[0].id
}

# Target HTTP Proxy for External LB
resource "google_compute_region_target_http_proxy" "lb_http_proxy" {
  count   = var.enable_load_balancer ? 1 : 0
  name    = "${var.lb_name}-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.lb_urlmap[0].id
}

# Forwarding Rule for External LB
resource "google_compute_forwarding_rule" "lb_forwarding_rule" {
  count                 = var.enable_load_balancer ? 1 : 0
  name                  = "${var.lb_name}-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
  ip_address            = google_compute_address.lb_ip[0].id
  target                = google_compute_region_target_http_proxy.lb_http_proxy[0].id
  port_range            = "80"
  network               = var.network_id
}
