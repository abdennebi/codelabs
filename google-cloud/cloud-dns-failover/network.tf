resource "google_compute_network" "app" {
  name                    = "app"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "region_1" {
  name = "${var.region_1}-subnet"
  region = var.region_1
  ip_cidr_range = "10.1.0.0/24"
  network       = google_compute_network.app.id
}

resource "google_compute_subnetwork" "region_2" {
  name = "${var.region_2}-subnet"
  region = var.region_2
  ip_cidr_range = "10.2.0.0/24"
  network       = google_compute_network.app.id
}