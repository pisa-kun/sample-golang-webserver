# modules/api_gateway/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region where the API Gateway will be deployed"
  type        = string
}

variable "api_display_name" {
  description = "Display name for the root API name"
  type        = string
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
  description = "The path to the local OpenAPI specification file path"
  type        = string
}

variable "func_url" {
  description = "Cloud Run service URL"
  type        = string
}
