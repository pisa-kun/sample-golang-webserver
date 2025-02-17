output "cloud_run_url" {
  value       = module.service-app.cloud_run_url
  description = "The URL of the deployed Cloud Run service"
}

output "api_gateway_url" {
  value       = module.api_gateway.gateway_url
  description = "The URL of the API Gateway"
}
