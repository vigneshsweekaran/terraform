# modules/vpc-network/main.tf

resource "google_compute_network" "custom_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Main subnet(e.g., for VMs, VPN server, etc.)
resource "google_compute_subnetwork" "main_subnet" {
  name          = "${var.vpc_name}-main-subnet"
  ip_cidr_range = var.main_subnet_cidr_range
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  private_ip_google_access = var.enable_private_ip_google_access
}

# Subnet specifically for Cloud Run Direct VPC Egress
# Note: Must be at least /26.
# This resource will only be created if 'create_cloudrun_egress_subnet' is true
resource "google_compute_subnetwork" "cloudrun_egress_subnet" {
  count = var.create_cloudrun_egress_subnet ? 1 : 0 # Conditional creation

  name                     = "${var.vpc_name}-cloudrun-egress-subnet"
  ip_cidr_range            = var.cloudrun_egress_subnet_cidr_range
  region                   = var.region
  network                  = google_compute_network.custom_vpc.id
  private_ip_google_access = var.enable_private_ip_google_access
}

# Example: Allow SSH within the VPC (for VMs with 'ssh' tag)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.vpc_name}-allow-ssh"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh"] # Example tag for VMs where you want to allow SSH
  source_ranges = ["0.0.0.0/0"]
}

# Example: Allow ICMP (ping) within the VPC
resource "google_compute_firewall" "allow_icmp_internal" {
  name    = "${var.vpc_name}-allow-icmp-internal"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "icmp"
  }

  source_ranges = concat(
    [google_compute_subnetwork.main_subnet.ip_cidr_range],
    var.create_cloudrun_egress_subnet ? [google_compute_subnetwork.cloudrun_egress_subnet[0].ip_cidr_range] : []
  )
}

resource "google_compute_firewall" "allow_vpn" {
  name    = "${var.vpc_name}-allow-vpn"
  network = google_compute_network.custom_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["943"]
  }

  allow {
    protocol = "udp"
    ports    = ["1194"]
  }

  target_tags   = ["vpn"]
  source_ranges = ["0.0.0.0/0"]
}


# General egress rule (often default-allow-egress is sufficient unless you delete it)
resource "google_compute_firewall" "allow_all_egress" {
  name    = "${var.vpc_name}-allow-all-egress"
  network = google_compute_network.custom_vpc.id
  
  direction     = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "all"
  }
  # This usually matches GCP's default behavior.
  # Add target_tags if you only want this to apply to specific VMs.
}

# PSC Subnet
resource "google_compute_subnetwork" "psc_subnet" {
  count         = var.enable_psc_subnet ? 1 : 0
  name          = var.psc_subnet_name
  ip_cidr_range = var.psc_subnet_range
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  purpose       = "PRIVATE_SERVICE_CONNECT"
}

# Proxy-only Subnet
resource "google_compute_subnetwork" "proxy_subnet" {
  count         = var.enable_proxy_subnet ? 1 : 0
  name          = var.proxy_subnet_name
  ip_cidr_range = var.proxy_subnet_range
  region        = var.region
  network       = google_compute_network.custom_vpc.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}