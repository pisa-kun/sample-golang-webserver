/**
 * # private-service-access
 *
 */

resource "google_compute_network" "this" {
  project = var.project_id
  name    = "private-network"
}

resource "google_compute_global_address" "this" {
  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.this.id
}

# There is an issue when deleting the resource
# https://github.com/hashicorp/terraform-provider-google/issues/16275
resource "google_service_networking_connection" "this" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.this.name]
}
