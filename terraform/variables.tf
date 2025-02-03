variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "ecr_repository_name" {
  description = "ecr repository name"
  default     = "app-runner-sample"
  type        = string
}

variable "app_runner_name" {
  description = "app runner name"
  default     = "app-runner-example"
  type        = string
}

variable "app_runner_role" {
  description = "attach role"
  default     = "app-runner-role"
  type        = string
}