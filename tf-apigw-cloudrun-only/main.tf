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
    #API Gatewayからの直接アクセスのみ受け付けるのでAPIGW側にrun.invokeのサービスアカウントを紐づける
    #service_account = google_service_account.service_app.email
  }
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project_id              = var.project_id
  region                  = var.region
  name                    = "api-gateway-dev"         # api root display name
  openapi_path            = "openApi.copy.yaml"
  func_url                = google_cloud_run_v2_service.this.uri
}
