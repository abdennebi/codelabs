resource "google_compute_network" "app" {
  name                    = "app"
  auto_create_subnetworks = false
}

# backend subnet
resource "google_compute_subnetwork" "app" {
  name          = "app"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.app.id
}

resource "google_compute_firewall" "health-check" {
  name          = "allow-health-check"
  direction     = "INGRESS"
  network       = google_compute_network.app.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
  }
  target_tags = ["allow-health-check"]
}