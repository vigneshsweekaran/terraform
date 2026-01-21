terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0"
    }
  }
}

# Apigee Organization
resource "google_apigee_organization" "org" {
  analytics_region    = var.region
  project_id          = var.project_id
  runtime_type        = "CLOUD"
  disable_vpc_peering = true
  billing_type        = var.billing_type
}

# Apigee Instance
resource "google_apigee_instance" "instance" {
  name     = "eval-instance"
  location = var.region
  org_id   = google_apigee_organization.org.id
  
  consumer_accept_list = [var.project_id]
}

# Apigee Environments (Loop based on variable)
resource "google_apigee_environment" "environments" {
  for_each = var.environments

  org_id       = google_apigee_organization.org.id
  name         = each.key
  display_name = coalesce(each.value.display_name, each.key)
  description  = coalesce(each.value.description, "Apigee Environment ${each.key}")
}

# Apigee Environment Group
resource "google_apigee_envgroup" "envgroup" {
  org_id    = google_apigee_organization.org.id
  name      = var.apigee_envgroup
  hostnames = [var.apigee_hostname]
}

# Attach Environments to Environment Group
resource "google_apigee_envgroup_attachment" "envgroup_attachments" {
  for_each = google_apigee_environment.environments

  envgroup_id = google_apigee_envgroup.envgroup.id
  environment = each.value.name
}

# Attach Instance to Environments
resource "google_apigee_instance_attachment" "instance_attachments" {
  for_each = google_apigee_environment.environments

  instance_id = google_apigee_instance.instance.id
  environment = each.value.name
}

# Helper local to flatten target servers
locals {
  # Create a list of objects like: { env_name = "dev", ts_name = "ts1", host = "...", ... }
  target_servers_flat = flatten([
    for env_name, env_config in var.environments : [
      for ts in env_config.target_servers : {
        env_name   = env_name
        name       = ts.name
        host       = ts.host
        port       = ts.port
        is_enabled = ts.is_enabled
        protocol   = ts.protocol
      }
    ]
  ])
}

# Target Servers
resource "google_apigee_target_server" "target_servers" {
  for_each = {
    for ts in local.target_servers_flat : "${ts.env_name}-${ts.name}" => ts
  }

  env_id      = google_apigee_environment.environments[each.value.env_name].id
  name        = each.value.name
  host        = each.value.host
  port        = each.value.port
  is_enabled  = each.value.is_enabled
  protocol    = each.value.protocol
}
