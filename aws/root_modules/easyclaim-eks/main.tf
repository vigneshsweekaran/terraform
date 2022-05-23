module "vpc" {
  source = "../../modules/eks/vpc"

  region                            = var.region
  vpc_cidr                          = var.vpc_cidr
  public_subnet1_cidr               = var.public_subnet1_cidr
  public_subnet1_availability_zone  = var.public_subnet1_availability_zone
  public_subnet2_cidr               = var.public_subnet2_cidr
  public_subnet2_availability_zone  = var.public_subnet2_availability_zone
  private_subnet1_cidr              = var.private_subnet1_cidr
  private_subnet1_availability_zone = var.private_subnet1_availability_zone
  private_subnet2_cidr              = var.private_subnet2_cidr
  private_subnet2_availability_zone = var.private_subnet2_availability_zone

  cluster_name                      = var.cluster_name  
}

# module "eks" {
#   source = "../../../modules/eks/cluster"

#   region     = var.region
#   access_key = var.access_key
#   secret_key = var.secret_key

#   environment_name = var.environment_name
#   cluster_name = var.cluster_name
#   vpc_id = local.vpc_id
#   public_subnet1_id = var.public_subnet1_id
#   public_subnet2_id = var.public_subnet2_id
#   private_subnet1_id = var.private_subnet1_id
#   private_subnet2_id = var.private_subnet2_id

#   eks_cluster_role           = var.eks_cluster_role
#   eks_node_group_role        = var.eks_node_group_role
#   fargate_pod_execution_role = var.fargate_pod_execution_role
#   fp_namespaces              = var.fp_namespaces

#   instance_type              = var.instance_type
#   node_autoscaling_min       = var.node_autoscaling_min
#   node_autoscaling_desired   = var.node_autoscaling_desired
#   node_autoscaling_max       = var.node_autoscaling_max
# }