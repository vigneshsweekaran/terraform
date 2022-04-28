variable "cluster_name" {
  type        = string
  description = "name of the cluster to execute the migration in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "list of subnets for the migration task"
}

variable "security_group_ids" {
  type        = list(string)
  description = "ids for the security groups to execute this migrations task in"
}

variable "task_definition_arn" {
  type        = string
  description = "ARN of the ecs task to run the migration with / in"
}

variable "container_name" {
  type        = string
  description = "name of the container to run the migration task with"
}
