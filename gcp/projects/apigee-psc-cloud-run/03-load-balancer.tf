# Reserve Regional External IP Address
resource "google_compute_address" "lb_ip" {
  name   = "${var.lb_name}-ip"
  region = var.region
}

# PSC Network Endpoint Group for Apigee
resource "google_compute_region_network_endpoint_group" "apigee_psc_neg" {
  name                  = "apigee-psc-neg"
  region                = var.region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"

  psc_target_service = google_apigee_instance.instance.service_attachment
  network            = google_compute_network.apigee_network.id
  subnetwork         = google_compute_subnetwork.main_subnet.id
}

# Regional Backend Service for External LB
resource "google_compute_region_backend_service" "apigee_backend" {
  name                  = "apigee-backend"
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTPS"

  backend {
    group           = google_compute_region_network_endpoint_group.apigee_psc_neg.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# URL Map for External LB
resource "google_compute_region_url_map" "lb_urlmap" {
  name            = "${var.lb_name}-url-map"
  region          = var.region
  default_service = google_compute_region_backend_service.apigee_backend.id
}

# Target HTTP Proxy for External LB
resource "google_compute_region_target_http_proxy" "lb_http_proxy" {
  name    = "${var.lb_name}-http-proxy"
  region  = var.region
  url_map = google_compute_region_url_map.lb_urlmap.id
}

# Forwarding Rule for External LB
resource "google_compute_forwarding_rule" "lb_forwarding_rule" {
  name                  = "${var.lb_name}-forwarding-rule"
  region                = var.region
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
  ip_address            = google_compute_address.lb_ip.id
  target                = google_compute_region_target_http_proxy.lb_http_proxy.id
  port_range            = "80"
  network               = google_compute_network.apigee_network.id
}
