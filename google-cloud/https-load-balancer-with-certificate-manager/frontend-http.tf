# reserved IP address
resource "google_compute_global_address" "app" {
  name = "app"
}

resource "google_compute_url_map" "app" {
  name            = "app"
  default_service = google_compute_backend_service.app_http.id
}

# http proxy
resource "google_compute_target_http_proxy" "app_http" {
  name    = "app-http"
  url_map = google_compute_url_map.app.id
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "app_http" {
  name        = "app-http"
  ip_protocol = "TCP"
  # see: https://cloud.google.com/load-balancing/docs/forwarding-rule-concepts#protocol-specifications
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.app_http.id
  ip_address            = google_compute_global_address.app.id
}

