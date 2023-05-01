
data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_id
}
data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_id
}
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_version = "1.24"
  cluster_name    = "sonarqube"
  cluster_endpoint_public_access = true
  vpc_id          = "vpc-01e1fb54b0dd55f4f"
  subnet_ids      = ["subnet-054e35f09c0d79dd6", "subnet-00905df181b5372b2", "subnet-065e96d7b556ba5e7"]

  cluster_addons = {
    kube-proxy = {}
    vpc-cni    = {}
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
      })
    }
  }
  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false
}
