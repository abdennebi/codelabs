

resource "google_compute_managed_ssl_certificate" "app" {
  name = "app"
  managed {
    domains = var.domains
  }

  lifecycle {
    ignore_changes = [
      name,
    ]
    create_before_destroy = true
  }
}

# More info: https://cloud.google.com/load-balancing/docs/ssl-policies-concepts
resource "google_compute_ssl_policy" "app" {
  name = "app"
}

resource "google_compute_target_https_proxy" "app_https" {
  name    = "app"
  url_map = google_compute_url_map.app.id
  ssl_certificates = [google_compute_managed_ssl_certificate.app.id]
  ssl_policy = google_compute_ssl_policy.app.id
}



resource "google_compute_global_forwarding_rule" "app_https" {
  name   = "app-https"
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range = 443
  target = google_compute_target_https_proxy.app_https.id
  ip_address            = google_compute_global_address.app.id

}