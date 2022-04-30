variable "frontend_image" {
  description = "frontend image name without tag"
  type        = string
  default     = "vigneshsweekaran/easyclaim-frontend"
}

variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "backend_image" {
  type        = string
  description = "backend docker image name without tag"
  default     = "vigneshsweekaran/easyclaim-backend"
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "access_key" {
  type    = string
  default = "AKIAXJ277CFQPC25KY6Z"
}

variable "secret_key" {
  type    = string
  default = "dgDV+g5eaDdkuE6ZTnetCChiKvWeawMKtrElGw0d"
}
