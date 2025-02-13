# modules/api_gateway/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region where the API Gateway will be deployed"
  type        = string
}

variable "name" {
  description = "Base name for API Gateway resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.name))
    error_message = "Name must start with a letter, end with a letter or number, and only contain lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name for resource labeling"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "stg", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stg, prod."
  }
}

variable "api_config_display_name" {
  description = "Display name for the API Gateway Config"
  type        = string
}

variable "gateway_display_name" {
  description = "Display name and The ID for the API Gateway Gateway"
  type        = string
}

variable "openapi_path" {
  description = "The path to the local OpenAPI specification file"
  type        = string
}

variable "func_url" {
  description = "Cloud Run service URL"
  type        = string
}

variable "create_api_key" {
  description = "Whether to create an API key"
  type        = bool
  default     = false
}
