locals {
  json_data = jsondecode(file("${path.module}/dev1-input.json"))
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc_id" {
  tags = var.filter_tags
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.main.id
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.main.id
}

locals {
  role_prefix = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role"
  eks_cluster_role = var.eks_cluster_role != "" ? var.eks_cluster_role : "${local.role_prefix}/eks-cluster-role"
  eks_node_group_role = var.eks_node_group_role != "" ? var.eks_node_group_role : "${local.role_prefix}/eks-node-group-role"
  fargate_pod_execution_role = var.fargate_pod_execution_role != "" ? var.fargate_pod_execution_role : "${local.role_prefix}/eks-fargate-pod-execution-role"
  vpc_id = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.vpc_id.id
}

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = join("/", ["/aws/eks", tostring(local.json_data.cluster_name), "cluster"])
  retention_in_days = 30

  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "eks-cloudwatch-log-group"])
    #Environment = var.environment
  }
}

resource "aws_eks_cluster" "main" {
  name     = tostring(local.json_data.cluster_name)
  role_arn = local.eks_cluster_role #add_role arn

  enabled_cluster_log_types = []

  vpc_config {
    subnet_ids = [tostring(local.json_data.public_subnet1_id), tostring(local.json_data.public_subnet2_id), tostring(local.json_data.private_subnet1_id), tostring(local.json_data.private_subnet2_id)]
  }

  timeouts {
    delete = "30m"
  }

  depends_on = [
    aws_cloudwatch_log_group.eks_cluster,
    #aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    #aws_iam_role_policy_attachment.AmazonEKSServicePolicy
  ]
}

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "chmod +x ./*sh"
    #interpreter = ["perl", "-e"]
  }
}

# Fetch OIDC provider thumbprint for root CA
data "external" "thumbprint" {
  program    = ["${path.module}/oidc_thumbprint.sh", tostring(local.json_data.region)]
  depends_on = [aws_eks_cluster.main, null_resource.example1]
}

/*resource "aws_iam_openid_connect_provider" "main" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.external.thumbprint.result.thumbprint]
  url             = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}*/

data "tls_certificate" "main" {
  url = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "example" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.main.certificates.0.sha1_fingerprint]
  url             = aws_eks_cluster.main.identity.0.oidc.0.issuer
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "kube-system"
  node_role_arn   = local.eks_node_group_role #add_role arn
  subnet_ids      = [tostring(local.json_data.private_subnet1_id), tostring(local.json_data.private_subnet2_id)]

  scaling_config {
    desired_size = var.node_autoscaling_desired
    max_size     = var.node_autoscaling_max
    min_size     = var.node_autoscaling_min
  }

  instance_types = [var.instance_type]

  #version = "1.18.5"

  tags = {
    Name = join("-", [tostring(local.json_data.cluster_name), "eks-node-group"])
    #Environment = var.environment
  }

  lifecycle {
    ignore_changes = [
      scaling_config.0.desired_size
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  #depends_on = [
  #aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
  #aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
  #aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  #]
}

data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    kubeconfig_name     = "eks_${aws_eks_cluster.main.name}"
    clustername         = aws_eks_cluster.main.name
    endpoint            = data.aws_eks_cluster.cluster.endpoint
    cluster_auth_base64 = data.aws_eks_cluster.cluster.certificate_authority[0].data
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = pathexpand("~/.kube/config")
}

output "kubectl_config" {
  description = "Path to new kubectl config file"
  value       = pathexpand("~/.kube/config")
}

output "cluster_id" {
  description = "ID of the created cluster"
  value       = aws_eks_cluster.main.id
}
