terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

resource "random_id" "name" {
  byte_length = 2
}

resource "google_sql_database_instance" "master" {
  provider             = google-beta
  name                 = "example-mysql-${random_id.name.hex}"
  project              = var.project
  region               = var.region
  database_version     = var.database_version
  master_instance_name = var.master_instance_name

  settings {
    tier              = var.tier
    activation_policy = var.activation_policy
    disk_autoresize   = var.disk_autoresize
    disk_size         = var.disk_size
    disk_type         = var.disk_type
    availability_type = var.availability_type

    dynamic "backup_configuration" {
      for_each = [var.backup_configuration]
      content {
        binary_log_enabled = lookup(backup_configuration.value, "binary_log_enabled", null)
        enabled            = lookup(backup_configuration.value, "enabled", null)
        start_time         = lookup(backup_configuration.value, "start_time", null)
      }
    }

    dynamic "ip_configuration" {
      for_each = [var.ip_configuration]
      content {
        ipv4_enabled    = lookup(ip_configuration.value, "ipv4_enabled", true)
        private_network = lookup(ip_configuration.value, "private_network", null)
        ssl_mode        = lookup(ip_configuration.value, "require_ssl", null) == true ? "TRUSTED_CLIENT_CERTIFICATE_REQUIRED" : null

        dynamic "authorized_networks" {
          for_each = lookup(ip_configuration.value, "authorized_networks", [])
          content {
            expiration_time = lookup(authorized_networks.value, "expiration_time", null)
            name            = lookup(authorized_networks.value, "name", null)
            value           = lookup(authorized_networks.value, "value", null)
          }
        }
      }
    }

    dynamic "location_preference" {
      for_each = [var.location_preference]
      content {
        follow_gae_application = lookup(location_preference.value, "follow_gae_application", null)
        zone                   = lookup(location_preference.value, "zone", null)
      }
    }

    dynamic "maintenance_window" {
      for_each = [var.maintenance_window]
      content {
        day          = lookup(maintenance_window.value, "day", null)
        hour         = lookup(maintenance_window.value, "hour", null)
        update_track = lookup(maintenance_window.value, "update_track", null)
      }
    }
  }

  dynamic "replica_configuration" {
    for_each = [var.replica_configuration]
    content {
      ca_certificate            = lookup(replica_configuration.value, "ca_certificate", null)
      client_certificate        = lookup(replica_configuration.value, "client_certificate", null)
      client_key                = lookup(replica_configuration.value, "client_key", null)
      connect_retry_interval    = lookup(replica_configuration.value, "connect_retry_interval", null)
      dump_file_path            = lookup(replica_configuration.value, "dump_file_path", null)
      failover_target           = lookup(replica_configuration.value, "failover_target", null)
      master_heartbeat_period   = lookup(replica_configuration.value, "master_heartbeat_period", null)
      password                  = lookup(replica_configuration.value, "password", null)
      ssl_cipher                = lookup(replica_configuration.value, "ssl_cipher", null)
      username                  = lookup(replica_configuration.value, "username", null)
      verify_server_certificate = lookup(replica_configuration.value, "verify_server_certificate", null)
    }
  }

  timeouts {
    create = "60m"
    delete = "2h"
  }
}

resource "google_sql_database" "default" {
  count     = var.master_instance_name == "" ? 1 : 0
  name      = var.db_name
  project   = var.project
  instance  = google_sql_database_instance.master.name
  charset   = var.db_charset
  collation = var.db_collation
}

resource "random_id" "user-password" {
  byte_length = 8
}

resource "google_sql_user" "default" {
  count    = var.master_instance_name == "" ? 1 : 0
  name     = var.user_name
  project  = var.project
  instance = google_sql_database_instance.master.name
  host     = var.user_host
  password = var.user_password == "" ? random_id.user-password.hex : var.user_password
}

