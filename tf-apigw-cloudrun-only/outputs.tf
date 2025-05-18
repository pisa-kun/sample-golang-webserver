output "cloud_run_url" {
  value       = module.service-app.cloud_run_url
  description = "The URL of the deployed Cloud Run service"
}

output "api_gateway_url" {
  value       = module.api_gateway.gateway_url
  description = "The URL of the API Gateway"
}


output "api_key" {
  value = module.api_gateway.api_key
  # API KeyをOutputする際に必要
  # echo -e "$(terraform output -raw api_key)"
  sensitive = true
}
