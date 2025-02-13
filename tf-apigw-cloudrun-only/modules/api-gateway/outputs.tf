# modules/api_gateway/outputs.tf

output "gateway_url" {
  description = "URL of the created API Gateway"
  value       = google_api_gateway_gateway.this.url
}

output "service_account_email" {
  description = "Email of the created service account"
  value       = google_service_account.gateway.email
}
