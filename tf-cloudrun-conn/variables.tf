variable "project_id" {
  description = "Google Cloud プロジェクトID"
  type        = string
}

variable "region" {
  description = "リージョン"
  type        = string
  default     = "us-central1"
}

variable "cloud_run_service_name" {
  description = "Cloud Run サービス名"
  type        = string
  default     = "hello-world-service"
}

variable "load_balancer_name" {
  description = "LoadBalancer 名"
  type        = string
  default     = "hello-world-lb"
}
