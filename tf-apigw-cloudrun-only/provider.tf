provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# API Gateway APIを有効化
resource "google_project_service" "apigateway" {
  project = var.project_id
  service = "apigateway.googleapis.com"
}
