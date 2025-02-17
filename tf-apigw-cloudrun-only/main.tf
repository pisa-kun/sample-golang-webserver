# リソースが1つの場合はthisにする
module "service-app" {
  source = "./modules/cloud-run"

  name                             = "service-app"
  region                           = var.region
  network_name                     = google_compute_network.this.name
  subnetwork_name                  = google_compute_network.this.name
  container_image                  = "gcr.io/cloudrun/hello"
}

module "api_gateway" {
  source = "./modules/api-gateway"

  project_id   = var.project_id
  region       = var.region
  name         = "api-gateway-dev" # api root display name
  openapi_path = "openApi.copy.yaml"
  backend_url  = module.service-app.cloud_run_url
}
