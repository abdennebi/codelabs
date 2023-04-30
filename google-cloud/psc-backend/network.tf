resource "google_compute_network" "consumer" {
  name                    = "consumer"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "consumer" {
  name          = "consumer"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.consumer.id
  private_ip_google_access = true
}

#There must be a single proxy-only subnet in the VPC network and region where you
#intend to create the internal HTTP(S) load balancer. This subnet is used by all
#internal HTTP(S) load balancers within that network and region.
resource "google_compute_subnetwork" "proxy-load-balancer" {
  name          = "proxy-load-balancer"
  ip_cidr_range = "10.100.100.0/24"
  network       = google_compute_network.consumer.id
  purpose = "INTERNAL_HTTPS_LOAD_BALANCER"
  role = "ACTIVE"
}