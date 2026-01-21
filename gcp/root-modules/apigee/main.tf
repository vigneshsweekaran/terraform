terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.16.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Network Module
module "vpc" {
  source = "../../modules/vpc"

  vpc_name               = var.vpc_network_name
  region                 = var.region
  main_subnet_cidr_range = var.subnet_range
  
  # PSC Subnet disabled by default
  enable_psc_subnet = false

  # Proxy Subnet enabled only if Load Balancer is enabled
  enable_proxy_subnet = var.enable_load_balancer
  proxy_subnet_name   = var.proxy_subnet_name
  proxy_subnet_range  = var.proxy_subnet_range
}

# Apigee Module
module "apigee" {
  source = "../../modules/apigee"

  project_id       = var.project_id
  region           = var.region
  apigee_envgroup  = var.apigee_envgroup
  apigee_hostname  = var.apigee_hostname

  # Define Environments and Target Servers
  environments = {
    dev = {
      display_name = "Development"
      description  = "Development Environment"
      target_servers = [
        {
          name       = "target-server-1"
          host       = "mocktarget.apigee.net"
          port       = 443
          is_enabled = true
        },
        {
          name       = "target-server-2"
          host       = "mocktarget.apigee.net"
          port       = 443
          is_enabled = true
        }
      ]
    }
    qa = {
      display_name = "QA"
      description  = "Quality Assurance Environment"
      target_servers = [
        {
          name       = "target-server-1"
          host       = "httpbin.org"
          port       = 443
          is_enabled = true
        },
        {
          name       = "target-server-2"
          host       = "httpbin.org"
          port       = 443
          is_enabled = true
        }
      ]
    }
  }
}

# Load Balancer Module
module "lb" {
  source = "../../modules/regional-external-loadbalancer"

  # Toggle Flag
  enable_load_balancer = var.enable_load_balancer

  project_id                = var.project_id
  region                    = var.region
  lb_name                   = var.lb_name
  apigee_service_attachment = module.apigee.service_attachment
  
  # Use IDs from VPC module
  network_id                = module.vpc.vpc_id
  subnet_id                 = module.vpc.main_subnet_id
}
