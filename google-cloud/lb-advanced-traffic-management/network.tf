resource "google_compute_network" "www" {
  name                    = "www"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "www" {
  for_each      = var.subnetworks
  name          = "subnet-${each.key}"
  region        = each.key
  network       = google_compute_network.www.self_link
  ip_cidr_range = each.value.cidr
}