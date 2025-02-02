output "load_balancer_ip" {
  description = "Load Balancer の IP アドレス"
  value       = google_compute_global_address.default.address
}

output "cloud_run_url" {
  description = "Cloud Run サービスの URL"
  value       = google_cloud_run_service.default.status[0]
}
