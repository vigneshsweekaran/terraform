# Enable Apigee API
resource "google_project_service" "apigee" {
  service            = "apigee.googleapis.com"
  disable_on_destroy = false
}

# Apigee Organization
resource "google_apigee_organization" "org" {
  analytics_region                     = var.region
  project_id                          = var.project_id
  runtime_type                        = "CLOUD"
  disable_vpc_peering                 = true
  
  depends_on = [google_project_service.apigee]
}

# Apigee Instance
resource "google_apigee_instance" "instance" {
  name     = "eval-instance"
  location = var.region
  org_id   = google_apigee_organization.org.id
  
  consumer_accept_list = [var.project_id]
}

# Apigee Environment
resource "google_apigee_environment" "environment" {
  org_id       = google_apigee_organization.org.id
  name         = var.apigee_env
  display_name = var.apigee_env
  description  = "Apigee Evaluation Environment"
}

# Apigee Environment Group
resource "google_apigee_envgroup" "envgroup" {
  org_id    = google_apigee_organization.org.id
  name      = var.apigee_envgroup
  hostnames = [var.apigee_hostname]
}

# Attach Environment to Environment Group
resource "google_apigee_envgroup_attachment" "envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.envgroup.id
  environment = google_apigee_environment.environment.name
}

# Attach Instance to Environment
resource "google_apigee_instance_attachment" "instance_attachment" {
  instance_id = google_apigee_instance.instance.id
  environment = google_apigee_environment.environment.name
}
