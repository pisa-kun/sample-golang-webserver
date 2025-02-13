# modules/api_gateway/outputs.tf

output "gateway_url" {
  description = "URL of the created API Gateway"
  value       = "https://${google_api_gateway_gateway.this.default_hostname}"
}

output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.gateway.email
}
