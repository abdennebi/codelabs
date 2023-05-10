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
  region = var.region_1
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
  region = var.region_2

  backend {
    group = google_compute_instance_group.ig-www-region2.id
  }

  # one of [EXTERNAL EXTERNAL_MANAGED INTERNAL INTERNAL_MANAGED ],
  load_balancing_scheme = "INTERNAL"

  # one of [HTTP HTTPS HTTP2 TCP SSL GRPC ]
  protocol = "TCP"
}



#resource "google_compute_address" "lb_ip" {
#  name         = "lb-ip"
#  subnetwork   = google_compute_subnetwork.producer_euw1.name
#  address_type = "INTERNAL"
#  address      = "10.0.2.10"
#}

resource "google_compute_forwarding_rule" "region1" {
  name                  = "www-ilb-tcp-${var.region_1}"
#  ip_address            = google_compute_address.lb_ip.id
  backend_service       = google_compute_region_backend_service.region1.id
  load_balancing_scheme = "INTERNAL"
  subnetwork            = google_compute_subnetwork.region_1.name
  ip_protocol           = "TCP"
  all_ports             = true
  region                = var.region_1
}

resource "google_compute_forwarding_rule" "region2" {
  name                  = "www-ilb-tcp-${var.region_2}"
  #  ip_address            = google_compute_address.lb_ip.id
  backend_service       = google_compute_region_backend_service.region2.id
  load_balancing_scheme = "INTERNAL"
  subnetwork            = google_compute_subnetwork.region_2.name
  ip_protocol           = "TCP"
  all_ports             = true
  region                = var.region_2
}
