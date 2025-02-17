variable "name" {
  description = "Cloud Run service name"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
}

variable "deletion_protection" {
  description = "If deletion protection is enabled"
  type        = bool
  default     = false
}

variable "max_instance_count" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 100
}

variable "max_instance_request_concurrency" {
  description = "Maximum number of concurrent requests per instance"
  type        = number
  default     = 200
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnetwork_name" {
  description = "VPC subnetwork name"
  type        = string
}

variable "egress" {
  description = "VPC egress settings"
  type        = string
  default     = "PRIVATE_RANGES_ONLY"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
  default     = ""
}
