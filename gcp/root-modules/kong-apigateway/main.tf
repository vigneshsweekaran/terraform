module "gcp_vpc_network" {
  source = "../../modules/vpc"

  vpc_name                        = "test-vpc"
  region                          = var.region
  main_subnet_cidr_range          = "10.10.0.0/20"
  enable_private_ip_google_access = true

  create_cloudrun_egress_subnet     = true
  cloudrun_egress_subnet_cidr_range = "10.10.16.0/26"
}

module "vpn_server_instance" {
  source = "../../modules/instance"
  region             = var.region
  instance_name      = "openvpn-server"
  zone               = "${var.region}-a"
  machine_type       = "e2-micro"
  network_name       = module.gcp_vpc_network.vpc_name
  subnetwork_name    = module.gcp_vpc_network.main_subnet_name
  assign_external_ip = true
  can_ip_forward     = true
  tags               = ["vpn", "ssh"]
}

module "service_account_kong_apigateway" {
  source = "../../modules/iam/service-account"

  service_account_id           = "kong-apigateway-cloud-run-sa"
  service_account_display_name = "Kong Apigateway Cloud Run Service Account"
  service_account_description  = "Kong Apigateway Cloud Run Service Account"
  gcs_bucket_name              = "vignesh-artifacts"
}

module "cloud_run_kong_apigateway" {
  source = "../../modules/cloud-run"

  region          = var.region
  service_account = module.service_account_kong_apigateway.service_account_email
  service_name    = "kong-apigateway"
  image_name      = "kong:3.9"
  port            = 8000

  allow_unauthenticated = true
  ingress               = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  vpc_name           = module.gcp_vpc_network.vpc_name
  vpc_subnet_name    = module.gcp_vpc_network.cloudrun_egress_subnet_name
  vpc_egress_setting = "PRIVATE_RANGES_ONLY"


  environment_variables = {
    KONG_DATABASE           = "off"
    KONG_DECLARATIVE_CONFIG = "/opt/kong/declarative/kong.yaml"
  }

  enable_gcs_volume = true
  volume_name       = "kong-config"
  mount_path        = "/opt/kong/declarative"
  bucket_name       = "vignesh-artifacts"
  volume_read_only  = true
}