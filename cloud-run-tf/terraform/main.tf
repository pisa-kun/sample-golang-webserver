resource "google_sql_database_instance" "postgres_instance" {
  name             = var.db_instance_name
  region           = var.region
  database_version = "POSTGRES_13"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        value = "0.0.0.0/0"
      }
    }
  }
}

resource "google_sql_database" "your_database" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}

resource "google_sql_user" "your_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = var.db_password
}

resource "google_cloud_run_v2_service" "your_service" {
  name     = "your-cloud-run-service"
  location = var.region

  template {
      containers {
        image = "us-central1-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.image_name}"
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
      }
    }
  }

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "policy" {
  location    = var.region
  name        = google_cloud_run_v2_service.your_service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}


resource "google_vpc_access_connector" "your_vpc_connector" {
  name   = "your-vpc-connector"
  region = var.region
  network = var.vpc_network
  ip_cidr_range = "10.8.0.0/28"  # CIDR範囲を指定
  max_instances    = 3
}
