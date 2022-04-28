variable "name" {
  type        = string
  description = "name for resources"
}

variable "service_discovery_registry_arn" {
  type        = string
  description = "arn of the service discovery registry"
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

variable "target_group_arn" {
  type        = string
  description = "ARN of the load balancer target group for this service"
}

variable "container_name" {
  type        = string
  description = "name of the container from the ecs task description to expose"
}

variable "container_port" {
  type        = number
  description = "port of the container from the ecs task description to expose"
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

variable "desired_count" {
  type        = number
  description = "Desired count for ecs service instances. This is only the initial count and defaults to ECSs default of 0."
  default     = 1
}

variable "deployment_maximum_percent" {
  type        = number
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment."
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  type        = number
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
  default     = 100
}
