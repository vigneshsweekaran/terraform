variable "dockerhub_password" {
  type        = string
  default     = ""
  description = "dockerhub password"
}

variable "github_oauth_token" {
  type        = string
  description = "GitHub OAuth Token with permissions to access private repositories"
  default     = ""
}
