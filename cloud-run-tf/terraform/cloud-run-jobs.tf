# Cloud Run Jobの設定
resource "google_cloud_run_v2_job" "your_cloud_run_job" {
  name     = "your-cloud-run-job"
  location = var.region

  template {
    template{
        timeout = "180s"
        max_retries = 3
        containers {
            image = "us-central1-docker.pkg.dev/${var.project_id}/${var.job_repository_name}/${var.job_image_name}:latest"
        # Cloud SQL接続用の環境変数を設定
            env {
                name  = "DB_HOST"
                value = google_sql_database_instance.postgres_instance.ip_address[0].ip_address
            }
            env {
                name  = "DB_USER"
                value = var.db_user
            }
            env {
                name  = "DB_PASSWORD"
                value = var.db_password
            }
            env {
                name  = "DB_NAME"
                value = var.db_name
            }
        }
        vpc_access {
        connector = google_vpc_access_connector.your_vpc_connector.id
        egress    = "ALL_TRAFFIC"
        }
    }
  }
}

# resource "google_cloud_run_v2_job_iam_policy" "job_iam_policy" {
#   location    = var.region
#   name        = google_cloud_run_v2_job.your_cloud_run_job.name
#   policy_data = data.google_iam_policy.noauth.policy_data
# }