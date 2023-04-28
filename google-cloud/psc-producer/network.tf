resource "google_compute_network" "vpc_producer" {
  name                    = "vpc-producer"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "producer_euw1" {
  name          = "producer-euw1"
  ip_cidr_range = "10.0.2.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_producer.id
}

resource "google_compute_subnetwork" "producer_nat" {
  name          = "producer-nat"
  ip_cidr_range = "192.168.0.0/24"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  network       = google_compute_network.vpc_producer.id
}

