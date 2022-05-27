# AWS
region     = "us-west-2"
access_key = ""
secret_key = ""

# VPC
vpc_cidr                          = "192.168.0.0/16"
public_subnet1_cidr               = "192.168.0.0/18"
public_subnet1_availability_zone  = "us-west-2a"
public_subnet2_cidr               = "192.168.64.0/18"
public_subnet2_availability_zone  = "us-west-2b"
private_subnet1_cidr              = "192.168.128.0/18"
private_subnet1_availability_zone = "us-west-2a"
private_subnet2_cidr              = "192.168.192.0/18"
private_subnet2_availability_zone = "us-west-2b"

# EKS
cluster_name             = "easyclaim"
instance_type            = "t2.medium"
node_autoscaling_min     = 1
node_autoscaling_desired = 1
node_autoscaling_max     = 3
fp_namespaces            = ["default", "dev"]
environment_name         = "dev"

# Deployment easyclaim frontend
namespace              = "dev"
frontend_image_name    = "vigneshsweekaran/easyclaim-frontend"
frontend_image_tag     = "latest"
frontend_replica_count = 1

# Deployment easyclaim backend
backend_image_name    = "vigneshsweekaran/easyclaim-backend"
backend_image_tag     = "latest"
backend_replica_count = 1