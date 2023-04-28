data "google_netblock_ip_ranges" "iap" {
  range_type = "iap-forwarders"
}

# Allow IAP to access VMs
resource "google_compute_firewall" "consumer-allow-iap" {
  name    = "consumer-allow-iap"
  network = google_compute_network.consumer.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }

  source_ranges = data.google_netblock_ip_ranges.iap.cidr_blocks_ipv4
}