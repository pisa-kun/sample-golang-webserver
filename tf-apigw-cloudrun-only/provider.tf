provider "google" {
  project = var.project_id
  region  = var.region

  // TODO: gcloud services enable iam.googleapis.com
  user_project_override = true
  billing_project = var.project_id
}

provider "google-beta" {
  project = var.project_id
  region  = var.region

  user_project_override = true
  billing_project = var.project_id
}

# API Gateway APIを有効化
# gcloud services enable apigateway.googleapis.com         # API Gateway API
# gcloud services enable servicemanagement.googleapis.com  # Service Management API
# gcloud services enable servicecontrol.googleapis.com     # Service Control API
# TODO: Destroy時にAPI無効化されるっぽいのでCLIで有効化必要
# resource "google_project_service" "apigateway" {
#   project = var.project_id
#   service = "apigateway.googleapis.com"
# }

# resource "google_project_service" "servicemanagement" {
#   project = var.project_id
#   service = "servicemanagement.googleapis.com"
# }

# resource "google_project_service" "servicecontrol" {
#   project = var.project_id
#   service = "servicecontrol.googleapis.com"
# }

# resource "google_project_service" "apikeys" {
#   project = var.project_id
#   service = "apikeys.googleapis.com"
# }
