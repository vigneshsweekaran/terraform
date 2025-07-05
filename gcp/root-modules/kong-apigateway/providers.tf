terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.40.0"
    }
  }
}

provider "google" {
  region = "us-central1"
}