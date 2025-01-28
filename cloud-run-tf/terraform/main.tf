resource "google_sql_database_instance" "postgres_instance" {
  name             = var.db_instance_name
  region           = var.region
  database_version = "POSTGRES_13"
  deletion_protection=false

  settings {
    tier = "db-f1-micro"
    // 
    ip_configuration {
      private_network = google_compute_network.vpc_network.id
      ipv4_enabled    = false
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
  deletion_protection=false
  #ingress  = "INGRESS_TRAFFIC_ALL"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
      containers {
        # latestを明示的につけないとイメージが切り替わらない
        image = "us-central1-docker.pkg.dev/${var.project_id}/${var.repository_name}/${var.image_name}:latest"
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


// network
resource "google_compute_network" "vpc_network" {
  name = "main-network"
}
resource "google_vpc_access_connector" "your_vpc_connector" {
  name   = "your-vpc-connector"
  region = var.region
  network = google_compute_network.vpc_network.id
  ip_cidr_range = "10.8.0.0/28"  # CIDR範囲を指定
  max_throughput = 500
  min_throughput = 200
}

# Private Service Access
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = "10.10.0.0"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}
resource "google_service_networking_connection" "default" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}