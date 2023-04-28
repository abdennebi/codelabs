resource "google_compute_service_attachment" "psc_ilb_service_attachment" {
  name                  = "www-psc-att"
  connection_preference = "ACCEPT_AUTOMATIC"
  enable_proxy_protocol = true
  nat_subnets           = [google_compute_subnetwork.producer_nat.id]
  target_service        = google_compute_forwarding_rule.default.id
}