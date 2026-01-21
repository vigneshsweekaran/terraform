variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "environments" {
  description = "Map of environments to create, with their target servers."
  type = map(object({
    display_name = optional(string)
    description  = optional(string)
    target_servers = optional(list(object({
      name        = string
      host        = string
      port        = number
      is_enabled  = optional(bool, true)
      protocol    = optional(string, "HTTP") # HTTP, HTTPS, TCP, SSL
      enable_ssl  = optional(bool)
    })), [])
  }))
  default = {
    eval = {
      display_name = "Evaluation Environment"
      description  = "Apigee Evaluation Environment"
      target_servers = []
    }
  }
}

variable "apigee_envgroup" {
  description = "Apigee Environment Group Name"
  type        = string
  default     = "eval-group"
}

variable "apigee_hostname" {
  description = "Apigee Hostname"
  type        = string
  default     = "api.example.com"
}

variable "billing_type" {
  description = "Apigee Billing Type (EVALUATION or SUBSCRIPTION)"
  type        = string
  default     = "EVALUATION"
}
