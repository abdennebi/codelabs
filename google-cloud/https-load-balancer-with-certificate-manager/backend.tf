resource "google_compute_health_check" "app_http" {
  name = "app-http"

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
}

# MIG
resource "google_compute_instance_group_manager" "app" {
  name     = "app"
  zone     = "us-central1-c"
  named_port {
    name = "http-port"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.app.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

resource "google_compute_backend_service" "app_http" {
  name                    = "app-http"
  protocol                = "HTTP"
  port_name               = "http-port"
  load_balancing_scheme   = "EXTERNAL"
  health_checks           = [google_compute_health_check.app_http.id]
  backend {
    group           = google_compute_instance_group_manager.app.instance_group
  }
}
