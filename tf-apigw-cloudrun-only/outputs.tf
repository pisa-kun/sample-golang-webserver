output "cloud_run_url" {
  value       = google_cloud_run_v2_service.service-app.uri
  description = "The URL of the deployed Cloud Run service"
}

output "api_gateway_url" {
  value       = "https://${google_api_gateway_gateway.api_gateway_gateway.default_hostname}"
  description = "The URL of the API Gateway"
}
