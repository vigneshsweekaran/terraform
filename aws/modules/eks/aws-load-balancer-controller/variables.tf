variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "alb_controller_chart_version" {
  description = "AWS ALB controller helm chart version"
  type        = string
}

variable "alb_controller_image_repository" {
  description = "AWS ALB Controller image repository"
  type        = string
}
