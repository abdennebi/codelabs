resource "google_compute_health_check" "http_health_check" {
  name = "http-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  http_health_check {
    port_name = "http"
    port      = 80
  }
}

resource "google_compute_region_backend_service" "region1" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.http_health_check.id]
  region        = var.region_1
  backend {
    group = google_compute_instance_group.ig-www-region1.id
  }

  # one of [EXTERNAL EXTERNAL_MANAGED INTERNAL INTERNAL_MANAGED ],
  load_balancing_scheme = "INTERNAL"

  # one of [HTTP HTTPS HTTP2 TCP SSL GRPC ]
  protocol = "TCP"
}

resource "google_compute_region_backend_service" "region2" {
  name          = "backend-service"
  health_checks = [google_compute_health_check.http_health_check.id]
  region        = var.region_2

  backend {
    group = google_compute_instance_group.ig-www-region2.id
  }

  # one of [EXTERNAL EXTERNAL_MANAGED INTERNAL INTERNAL_MANAGED ],
  load_balancing_scheme = "INTERNAL"

  # one of [HTTP HTTPS HTTP2 TCP SSL GRPC ]
  protocol = "TCP"
}


resource "google_compute_address" "lb_ip_region1" {
  name         = "lb-ip-${var.region_1}"
  subnetwork   = google_compute_subnetwork.region_1.id
  address_type = "INTERNAL"
  region       = var.region_1
}

resource "google_compute_address" "lb_ip_region2" {
  name         = "lb-ip-${var.region_2}"
  subnetwork   = google_compute_subnetwork.region_2.id
  address_type = "INTERNAL"
  region       = var.region_2
}

resource "google_compute_forwarding_rule" "region1" {
  name                  = "www-ilb-tcp-${var.region_1}"
  ip_address            = google_compute_address.lb_ip_region1.id
  backend_service       = google_compute_region_backend_service.region1.id
  load_balancing_scheme = "INTERNAL"
  network               = google_compute_network.app.id
  subnetwork            = google_compute_subnetwork.region_1.name
  ip_protocol           = "TCP"
  all_ports             = true
  region                = var.region_1
  # It's mandatory to enable global access : https://cloud.google.com/load-balancing/docs/internal/setting-up-internal#ilb-global-access
  allow_global_access   = true
}

resource "google_compute_forwarding_rule" "region2" {
  name                  = "www-ilb-tcp-${var.region_2}"
  ip_address            = google_compute_address.lb_ip_region2.id
  backend_service       = google_compute_region_backend_service.region2.id
  load_balancing_scheme = "INTERNAL"
  subnetwork            = google_compute_subnetwork.region_2.name
  ip_protocol           = "TCP"
  all_ports             = true
  region                = var.region_2
}
