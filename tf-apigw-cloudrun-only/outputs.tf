output "cloud_run_url" {
  value       = google_cloud_run_v2_service.this.uri
  description = "The URL of the deployed Cloud Run service"
}

output "api_gateway_url" {
  value       = module.api_gateway.gateway_url
  description = "The URL of the API Gateway"
}
