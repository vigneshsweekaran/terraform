variable "name" {
  type        = string
  description = "name for resources"
}

variable "cluster_id" {
  type        = string
  description = "id of the ecs cluster to create the service in"
}

variable "tags" {
  type        = map(any)
  description = "tags to append to resources where applicable"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of subnet ids for the ECS services ENIs."
}

variable "security_groups" {
  type        = list(string)
  description = "list of security groups this service should be part of"
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the task definition to use for this service"
}

variable "assign_public_ip" {
  type        = bool
  description = "Assign a public IP address to the ENI"
  default     = false
}
