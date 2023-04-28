# see: https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/netblock_ip_ranges
data "google_netblock_ip_ranges" "legacy-hcs" {
  range_type = "legacy-health-checkers"
}

data "google_netblock_ip_ranges" "iap" {
  range_type = "iap-forwarders"
}

# Allow Google health checkers to reach VMs
resource "google_compute_firewall" "allow-hcs" {
  name    = "allow-hcs"
  network = google_compute_network.vpc_producer.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = data.google_netblock_ip_ranges.legacy-hcs.cidr_blocks_ipv4
}

# Allow IAP to access VMs
resource "google_compute_firewall" "allow-iap" {
  name    = "allow-iap"
  network = google_compute_network.vpc_producer.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }

  source_ranges = data.google_netblock_ip_ranges.iap.cidr_blocks_ipv4
}

# Allow traffic from PSC NAT subnet to VMs subnet
resource "google_compute_firewall" "allow-psc-clients" {
  name    = "allow-psc-clients"
  network = google_compute_network.vpc_producer.name

  source_ranges = ["192.168.0.0/24"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  log_config {
    metadata = "EXCLUDE_ALL_METADATA"
  }
}




