module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 11.0"

  project_id   = var.project_id
  network_name = "${var.project_name}-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${var.project_name}-main-subnet"
      subnet_ip             = var.main_subnet_cidr_range
      subnet_region         = var.region
      subnet_private_access = true # Enable Private Google Access
    },
    {
      subnet_name           = "${var.project_name}-cloudrun-egress-subnet"
      subnet_ip             = var.cloudrun_egress_subnet_cidr_range
      subnet_region         = var.region
      subnet_private_access = true # Enable Private Google Access for Cloud Run egress
    },
  ]

  firewall_rules = [
    {
      name        = "${var.project_name}-allow-openvpn"
      description = "Allow OpenVPN UDP/TCP traffic to VPN server"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      target_tags = ["vpn"]
      allow = [{
        protocol = "udp"
        ports    = ["1194"]
      },
      {
        protocol = "tcp"
        ports    = ["943"]
      }]
    },
    # Allow SSH (TCP 22) to VPN server from anywhere
    {
      name        = "${var.project_name}-allow-ssh"
      description = "Allow SSH TCP traffic"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      target_tags = ["ssh"]

      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
    },
    # Allow all egress (outbound) traffic for the entire VPC
    {
      name        = "${var.project_name}-allow-all-egress"
      description = "Allow all outbound traffic from the VPC"
      direction   = "EGRESS"
      priority    = 1000
      ranges      = ["0.0.0.0/0"]
      # No target_tags or source_tags, applies to all VMs in the network.
      allow = [{
        protocol = "all"
      }]
    },
    # Allow internal VPC communication (e.g., between VMs on different subnets)
    {
      name        = "${var.project_name}-allow-internal"
      description = "Allow internal traffic within the VPC"
      direction   = "INGRESS"
      priority    = 1000
      ranges      = [var.main_subnet_cidr_range, var.cloudrun_egress_subnet_cidr_range]
      # No target_tags, applies to all instances in the network.
      allow = [{
        protocol = "all"
      }]
    }
  ]
}