terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.40.0"
    }
  }
}

provider "google" {
  region = "us-central1"
}

resource "google_compute_instance" "instance" {
  name         = "test"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
  }
}