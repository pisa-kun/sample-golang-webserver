# サービスアカウントの作成
# API Gatewayのサービスアカウントを作成
resource "google_service_account" "gateway" {
  project      = var.project_id
  account_id   = "api-gateway-account"
  display_name = "api-gateway-account"
}
# API GatewayのサービスアカウントにIAMポリシーを付与
# cloud runへアクセスできるように許可追加
resource "google_project_iam_member" "this" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.gateway.email}"
}

# API Gatewayの作成
resource "google_api_gateway_api" "this" {
  provider = google-beta
  api_id   = "api-gateway" # 任意
  project  = var.project_id
}

# API Configの作成
resource "google_api_gateway_api_config" "this" {
  provider     = google-beta
  project      = var.project_id
  api          = google_api_gateway_api.this.api_id
  display_name = "api-gateway-config" # 任意
  gateway_config {
    backend_config {
      google_service_account = google_service_account.gateway.email
    }
  }

  openapi_documents {
    document {
      path = "https://github.com/pisa-kun/sample-golang-webserver/blob/main/tf-apigw-cloudrun-only/openApi.yaml"
      # terraform apply時にcloud runのurlを外部注入する
      contents = base64encode(templatefile("openApi.yaml", {
        func_url = google_cloud_run_v2_service.this.uri
      }))
    }
  }
}

# ゲートウェイの作成
resource "google_api_gateway_gateway" "this" {
  provider   = google-beta
  project    = var.project_id
  region     = var.region
  api_config = google_api_gateway_api_config.this.id
  gateway_id = "api-gateway"
}
