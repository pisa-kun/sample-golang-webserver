provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.cloud_run_service_name
  location = var.region
  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        ports {
          container_port = 8080
        }
      }
    }
  }
  
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# HTTP(S) LoadBalancer
resource "google_compute_global_forwarding_rule" "default" {
  name        = "${var.load_balancer_name}-rule"
  target      = google_compute_target_http_proxy.default.id
  port_range  = "80"
  ip_address  = google_compute_global_address.default.address
}

resource "google_compute_global_address" "default" {
  name = "${var.load_balancer_name}-ip"
}

resource "google_compute_url_map" "default" {
  name = "${var.load_balancer_name}-url-map"
  default_service = google_compute_backend_service.default.id

    host_rule {
    hosts        = ["*"]
    path_matcher = "default"
  }

    path_matcher {
    name            = "default"
    default_service = google_compute_backend_service.default.self_link
    }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.load_balancer_name}-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_backend_service" "default" {
  name        = "${var.load_balancer_name}-backend-service"
  protocol    = "HTTP"
  timeout_sec = 30
  backend {
    group = google_compute_region_network_endpoint_group.cloudrun_neg.id
  }
  enable_cdn = false
}

resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  provider              = google-beta
  name                  = "${var.cloud_run_service_name}-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.default.name
  }
}
