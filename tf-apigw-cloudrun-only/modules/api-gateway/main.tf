# modules/api_gateway/main.tf

resource "google_service_account" "gateway" {
  account_id  = var.name
  project     = var.project_id
  description = "Service Account for Sample API Gateway"
}

resource "google_project_iam_member" "this" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

resource "google_api_gateway_api" "this" {
  provider     = google-beta
  project      = var.project_id
  api_id       = var.name
  display_name = var.name
}

resource "google_api_gateway_api_config" "this" {
  provider     = google-beta
  project      = var.project_id
  api          = google_api_gateway_api.this.api_id
  display_name = var.name
  gateway_config {
    backend_config {
      google_service_account = google_service_account.gateway.email
    }
  }

  openapi_documents {
    document {
      path = var.openapi_path
      contents = base64encode(templatefile(var.openapi_path, {
        func_url = var.backend_url
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "this" {
  provider     = google-beta
  project      = var.project_id
  region       = var.region
  api_config   = google_api_gateway_api_config.this.id
  gateway_id   = var.name
  display_name = var.name
}
