module "deployment" {
  source = "../../../modules/easyclaim"
  providers = {
    aws         = aws
  }

  name                         = "dev"
  worker_desired_count         = 3
  name_env                     = "dev"
  backend_image                = "${var.backend_image}:${var.backend_image_tag}"
  frontend_image               = "${var.frontend_image}:${var.frontend_image_tag}"
  enable_frontend_autoscaling  = false
  enable_backend_autoscaling   = false
  deletion_protection          = false
  log_retention_days           = 3
  tags                         = {}
}