# modules/api_gateway/main.tf

resource "google_service_account" "this" {
  account_id   = "${var.name}-sa"
  display_name = "Service Account for ${var.name} API Gateway"
  description  = "Service account for API Gateway to invoke Cloud Run services"
  project      = var.project_id
}

resource "google_project_iam_member" "this" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_api_gateway_api" "this" {
  provider     = google-beta
  project      = var.project_id
  api_id       = var.name
  display_name = var.name
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_api_gateway_api_config" "this" {
  provider     = google-beta
  project      = var.project_id
  api          = google_api_gateway_api.this.api_id
  display_name = var.api_config_display_name

  gateway_config {
    backend_config {
      google_service_account = google_service_account.this.email
    }
  }

  openapi_documents {
    document {
      path = var.openapi_path
      contents = base64encode(templatefile(var.openapi_path, {
        func_url = var.func_url
      }))
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_api_gateway_gateway" "this" {
  provider     = google-beta
  project      = var.project_id
  region       = var.region
  api_config   = google_api_gateway_api_config.this.id
  gateway_id   = var.gateway_display_name
  display_name = var.gateway_display_name
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "google_apikeys_key" "this" {
  count        = var.create_api_key ? 1 : 0
  provider     = google-beta
  project      = var.project_id
  name         = "${var.name}-key"
  display_name = "${var.name} API Key"

  restrictions {
    api_targets {
      service = google_api_gateway_api.this.managed_service
    }
  }
}
