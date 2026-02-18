module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/gke-autopilot-cluster"
  version = "43.0.0"

  project_id = var.project_id
  name       = var.cluster_name
  location   = var.region
  network    = module.vpc.network_name
  subnetwork = "gke-subnet"

  ip_allocation_policy = {
    cluster_secondary_range_name  = var.ip_range_pods_name
    services_secondary_range_name = var.ip_range_services_name
  }

  workload_identity_config = {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  private_cluster_config = {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }

  master_authorized_networks_config = {
    cidr_blocks = [
      {
        display_name = "Bastion Subnet"
        cidr_block   = "10.0.1.0/25"
      }
    ]
  }
}
