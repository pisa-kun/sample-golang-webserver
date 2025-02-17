# modules/api_gateway/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "The Google Cloud region where resources will be provisioned."
  default     = "asia-northeast1"
  type        = string
}

variable "name" {
  description = "Base name for API Gateway resources"
  type        = string
}

variable "openapi_path" {
  description = "The path to the local OpenAPI specification file path"
  type        = string
}

variable "backend_url" {
  description = "Cloud Run service URL"
  type        = string
}
