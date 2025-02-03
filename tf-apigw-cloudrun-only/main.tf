# リソースが1つの場合はthisにする
resource "google_cloud_run_v2_service" "this" {
  name                = "service-app"
  location            = var.region
  deletion_protection = false
  template {
    scaling {
      max_instance_count = 100
    }
    max_instance_request_concurrency = 200

    vpc_access {
      network_interfaces {
        network    = google_compute_network.this.name
        subnetwork = google_compute_network.this.name
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
    containers {
      image = "gcr.io/cloudrun/hello"
    }
    service_account = google_service_account.service_app.email
  }
}

resource "google_service_account" "service_app" {
  account_id = "service-app"
}

locals {
  gcp = {
    devs = [
      "test@gmail.com"
    ]
  }
}

resource "google_cloud_run_service_iam_member" "this" {
  for_each = toset(local.gcp.devs)

  location = google_cloud_run_v2_service.this.location
  project  = google_cloud_run_v2_service.this.project
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  #member   = "allUsers"
  member = "user:${each.key}"
}
