resource "google_compute_address" "external_ip" {
  name    = "${var.instance_name}-external-ip"
  region  = var.region
  count   = var.assign_external_ip ? 1 : 0
}

resource "google_compute_instance" "default" {
  name         = var.instance_name
  zone         = var.zone
  machine_type = var.machine_type

  # Crucial for VPN server: Enable IP forwarding
  can_ip_forward = var.can_ip_forward

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
    # Assign external IP if enabled
    dynamic "access_config" {
      for_each = var.assign_external_ip ? [1] : []
      content {
        nat_ip = google_compute_address.external_ip[0].address
      }
    }
  }

  metadata_startup_script = var.user_data # Pass user_data here

  tags = var.tags # Apply tags for firewall rules
}