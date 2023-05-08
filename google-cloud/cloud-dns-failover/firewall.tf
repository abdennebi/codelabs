data "google_netblock_ip_ranges" "iap" {
  range_type = "iap-forwarders"
}
data "google_netblock_ip_ranges" "legacy-hcs" {
  range_type = "legacy-health-checkers"
}

# Allow Google health checkers to reach VMs
resource "google_compute_firewall" "allow-hcs" {
  name    = "app-allow-hcs"
  network = google_compute_network.app.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }

  source_ranges = data.google_netblock_ip_ranges.legacy-hcs.cidr_blocks_ipv4
}


# Allow IAP to access VMs
resource "google_compute_firewall" "allow-iap" {
  name    = "app-allow-iap"
  network = google_compute_network.app.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }

  source_ranges = data.google_netblock_ip_ranges.iap.cidr_blocks_ipv4
}