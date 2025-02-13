# modules/api_gateway/variables.tf

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region where the API Gateway will be deployed"
  type        = string
}

variable "api_id" {
  description = "The API Gateway ID"
  type        = string
}

variable "api_config_display_name" {
  description = "Display name for the API Gateway Config"
  type        = string
}

variable "openapi_path" {
  description = "The path to the OpenAPI specification file"
  type        = string
}

variable "openapi_template" {
  description = "The OpenAPI template file"
  type        = string
}

variable "func_url" {
  description = "Cloud Run service URL"
  type        = string
}

variable "gateway_id" {
  description = "The ID of the API Gateway"
  type        = string
}

variable "api_gateway_display_name" {
  description = "Display name for the API Gateway Gateway"
  type        = string
}
