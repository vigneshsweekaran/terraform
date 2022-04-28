variable "name" {
  type        = string
  description = "name for resources"
}

# default is the minumum as of 13/11/2019
# See
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
#
variable "cpu" {
  type        = number
  description = "instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = 1024
}

# default is the minumum as of 13/11/2019
# See
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
#
variable "memory" {
  type        = number
  description = "instance memory to provision (in MiB)"
  default     = 2048
}

# default is the minumum as 21GiB, maximum value is 200GiB
# See
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_definition_ephemeralStorage
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#ephemeral_storage
#
variable "ephemeral_storage_size" {
  type        = number
  description = "instance ephemeral_storage to provision (in GiB)"
  default     = 21
}

# See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
#
variable "container_definitions" {
  type        = string
  description = <<EOF
  Container definitions document as json, as required by ECS

  https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  EOF
}

variable "task_role_arn" {
  type        = string
  description = "The ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "tags to append to resources where applicable"
  default     = {}
}
