# VPC Network
resource "google_compute_network" "apigee_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Main Subnet (used by Cloud Run ILB and PSC NEG)
resource "google_compute_subnetwork" "main_subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_range
  region        = var.region
  network       = google_compute_network.apigee_network.id
}

# PSC Subnet (for PSC service attachments NAT)
resource "google_compute_subnetwork" "psc_subnet" {
  name          = var.psc_subnet_name
  ip_cidr_range = var.psc_subnet_range
  region        = var.region
  network       = google_compute_network.apigee_network.id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

# Proxy-only Subnet (for External Load Balancer)
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = var.proxy_subnet_name
  ip_cidr_range = var.proxy_subnet_range
  region        = var.region
  network       = google_compute_network.apigee_network.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
