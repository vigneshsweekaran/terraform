module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "15.2.0"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "gke-subnet"
      subnet_ip             = "10.0.0.0/25"
      subnet_region         = var.region
      subnet_private_access = true
    },
    {
      subnet_name   = "bastion-subnet"
      subnet_ip     = "10.0.1.0/25"
      subnet_region = var.region
    }
  ]

  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.1.0.0/21"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.0.0.128/25"
      },
    ]
  }
}
