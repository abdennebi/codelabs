

resource "google_dns_managed_zone" "kms" {
  name        = "kms"
  dns_name    = local.dns_name
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.consumer.id
    }
  }
}

resource "google_dns_record_set" "kms" {
  name         = "${var.region}.${local.dns_name}"
  managed_zone = google_dns_managed_zone.kms.name
  type         = "A"
  ttl          = 300
  rrdatas = [google_compute_address.kms.address]
}