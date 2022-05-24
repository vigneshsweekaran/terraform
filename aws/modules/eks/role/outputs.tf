output "eks_cluster_role" {
  description = "EKS cluster role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_group_role" {
  description = "EKS Node group role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "fargate_pod_execution_role" {
  description = "EKS pod execution role"
  value       = aws_iam_role.fargate_pod_execution_role.arn
}