# Cloud NAT is used by VM not having public IP to access Internet to download packages.
# Cloud NAT uses Cloud Router only to group NAT configuration information (control plane).
# Cloud NAT does not direct a Cloud Router to use BGP or to add routes. NAT traffic does not
# pass through a Cloud Router (data plane). See https://cloud.google.com/nat/docs/gce-example

resource "google_compute_router" "nat_region1" {
  name    = "nat-cloud-router-${var.region_1}"
  network = google_compute_network.app.name
  region = var.region_1
}

resource "google_compute_router" "nat_region2" {
  name    = "nat-cloud-router-${var.region_2}"
  network = google_compute_network.app.name
  region = var.region_2
}

resource "google_compute_router_nat" "nat_region1" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_region1.name
  region                             = google_compute_router.nat_region1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router_nat" "nat_region2" {
  name                               = "nat-gateway"
  router                             = google_compute_router.nat_region2.name
  region                             = google_compute_router.nat_region2.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}