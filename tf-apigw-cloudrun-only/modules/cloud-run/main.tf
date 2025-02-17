resource "google_cloud_run_v2_service" "this" {
  name                = var.name
  location            = var.region
  deletion_protection = var.deletion_protection
  template {
    scaling {
      max_instance_count = var.max_instance_count
    }
    max_instance_request_concurrency = var.max_instance_request_concurrency

    vpc_access {
      network_interfaces {
        network    = var.network_name
        subnetwork = var.subnetwork_name
      }
      egress = var.egress
    }
    containers {
      image = var.container_image
    }
    service_account = var.service_account_email
  }
}
