module "deployment" {
  source = "../../../modules/easyclaim"
  providers = {
    aws         = aws
  }

  name                         = "qa"
  worker_desired_count         = 3
  name_env                     = "qa"
  backend_image                = "${var.backend_image}:${var.backend_image_tag}"
  frontend_image               = "${var.frontend_image}:${var.frontend_image_tag}"
  deletion_protection          = false
  log_retention_days           = 3
  tags                         = {}
}