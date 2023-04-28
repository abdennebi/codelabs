resource "google_compute_network" "consumer" {
  name                    = "consumer"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer" {
  name          = "consumer"
  ip_cidr_range = "10.0.60.0/24"
  network       = google_compute_network.consumer.id
}

resource "google_compute_address" "consumer-ip" {
  name         = "consumer-ip"
  subnetwork   = google_compute_subnetwork.consumer.name
  address_type = "INTERNAL"
  address      = "10.0.60.100"
}
