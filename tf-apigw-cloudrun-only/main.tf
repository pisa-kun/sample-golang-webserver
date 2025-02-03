resource "google_cloud_run_v2_service" "service-app" {
  name     = "service-app"
  location = var.region
  deletion_protection=false
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
    #         network_interfaces {
    #     network    = "private-network"
    #     subnetwork = "private-network"
    #   }
      egress = "PRIVATE_RANGES_ONLY"
    }
    containers {
      image = "gcr.io/cloudrun/hello"
    }
    service_account = google_service_account.service-app.email
  }
}

resource "google_service_account" "service-app" {
  account_id = "service-app"
}

resource "google_cloud_run_service_iam_member" "member" {
  location = google_cloud_run_v2_service.service-app.location
  project  = google_cloud_run_v2_service.service-app.project
  service  = google_cloud_run_v2_service.service-app.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}