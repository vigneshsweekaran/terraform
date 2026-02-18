resource "google_compute_instance" "bastion" {
  name         = "bastion-host"
  machine_type = "e2-micro"
  zone         = "${var.region}-a"
  tags         = ["bastion"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = module.vpc.network_name
    subnetwork = module.vpc.subnets_names[1]

    # No external IP for secure bastion (requires IAP)
    # access_config {} 
  }

  service_account {
    scopes = ["cloud-platform"]
  }
  
  metadata = {
    enable-oslogin = "TRUE"
  }
}

# Firewall rule to allow SSH via IAP
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "allow-iap-ssh"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"] # IAP range
  target_tags   = ["bastion"]
}
