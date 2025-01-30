# サービスアカウントの作成
# API Gatewayのサービスアカウントを作成
resource "google_service_account" "api-gateway-service-account" {
  project = var.project_id
  account_id   = "dev-terraform-service-account"
  display_name = "terraform_service_account"
}
# API GatewayのサービスアカウントにIAMポリシーを付与
resource "google_project_iam_member" "api-gateway-service-account" {
  project = var.project_id
  role = "roles/run.invoker" # 任意のバックエンドサービスに則ったロールを設定
  member = "serviceAccount:${google_service_account.api-gateway-service-account.email}"
}

# API Gatewayの作成
resource "google_api_gateway_api" "api-gateway" {
    provider = google-beta
    api_id = "my-api-gateway" # 任意
    project = var.project_id
}

# API Configの作成
resource "google_api_gateway_api_config" "api_gateway_config" {
    provider =  google-beta
    project = var.project_id
    api = google_api_gateway_api.api-gateway.api_id
    display_name = "my-api-gateway-config" # 任意
    gateway_config {
      backend_config {
        google_service_account = google_service_account.api-gateway-service-account.email
      }
    }

    openapi_documents {
      document {
        # ローカルのファイルを指定
        # path = "openApi.yaml"
        # githubのpathも指定可能
        # 参照するyamlを切り替えること可能
        # path = "https://github.com/pisa-kun/sample-golang-webserver/blob/main/cloud-run-tf/terraform/openApi2.yaml"
        # contents = filebase64("openApi2.yaml")
        path = "https://github.com/pisa-kun/sample-golang-webserver/blob/main/cloud-run-tf/terraform/authApi.yaml"
        # terraform apply時にcloud runのurlを外部注入する
        contents = base64encode(templatefile("authApi.yaml",{
          func_url = google_cloud_run_v2_service.your_service.uri
        }))
      }
    }

    lifecycle {
      create_before_destroy = true
    }
}

# ゲートウェイの作成
resource "google_api_gateway_gateway" "api_gateway_gateway" {
  provider = google-beta
  project = var.project_id
  region = var.region
  api_config = google_api_gateway_api_config.api_gateway_config.id
  gateway_id = "my-api-gateway"
}