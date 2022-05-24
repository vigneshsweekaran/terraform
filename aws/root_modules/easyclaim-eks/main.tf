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

  cluster_name = var.cluster_name
}

module "role" {
  source = "../../modules/eks/role"
}

module "eks" {
  source = "../../modules/eks/cluster"

  environment_name   = var.environment_name
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  public_subnet1_id  = module.vpc.public_subnet1_id
  public_subnet2_id  = module.vpc.public_subnet2_id
  private_subnet1_id = module.vpc.private_subnet1_id
  private_subnet2_id = module.vpc.private_subnet2_id

  eks_cluster_role           = module.role.eks_cluster_role
  eks_node_group_role        = module.role.eks_node_group_role
  fargate_pod_execution_role = module.role.fargate_pod_execution_role
  fp_namespaces              = var.fp_namespaces

  instance_type            = var.instance_type
  node_autoscaling_min     = var.node_autoscaling_min
  node_autoscaling_desired = var.node_autoscaling_desired
  node_autoscaling_max     = var.node_autoscaling_max
}