resource "google_compute_forwarding_rule" "default" {
  provider              = google
  name                  = "psc-endpoint"

  #  In Private Service Connect Forwarding Rule. This field should be set empty string.
  load_balancing_scheme = ""

  target                = "projects/${var.producer_project_id}/regions/${var.producer_region}/serviceAttachments/${var.producer_attachment_name}"
  network               = google_compute_network.consumer.name
  ip_address            = google_compute_address.consumer-ip.id
}