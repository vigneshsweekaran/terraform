resource "google_compute_address" "external_ip" {
  name    = "openvpn-server-external-ip"
  region  = var.region
}

resource "google_compute_instance" "instance" {
  name         = "openvpn-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "${var.project_name}-vpc"
    subnetwork = "${var.project_name}-main-subnet"
    access_config {
      nat_ip = google_compute_address.external_ip.address
    }
  }

  tags = ["vpn", "ssh"]
}