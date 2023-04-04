module "aws-lb-controller" {
  source = "../../../modules/eks/aws-load-balancer-controller"

  cluster_name = var.cluster_name
  alb_controller_chart_version = var.alb_controller_chart_version
  alb_controller_image_repository = var.alb_controller_image_repository
}

module "sample-app" {
  source = "../../../modules/k8s/app"
  count = var.include_sample_app ? 1 : 0

  name                         = "sample-app"
  namespace                    = var.namespace
  image_name                   = var.frontend_image_name
  image_tag                    = var.frontend_image_tag
  replica_count                = var.frontend_replica_count
  healthcheck_path             = var.healthcheck_path
  healthcheck_port             = var.healthcheck_port
  host                         = var.host
  alb_group_name               = var.alb_group_name
  enable_hpa                   = false
  enable_lb_soureip            = var.enable_lb_soureip
  ingress_annotations_sourceip = var.ingress_annotations_sourceip

  depends_on = [
    module.aws-lb-controller
  ]
}