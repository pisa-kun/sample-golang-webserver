# Cloud Run Jobの設定
resource "google_cloud_run_v2_job" "your_cloud_run_job" {
  name     = "your-cloud-run-job"
  location = var.region
  deletion_protection=false

  template {
    template{
        timeout = "180s"
        max_retries = 3
        containers {
            image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.job_repository_name}/${var.job_image_name}:latest"
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