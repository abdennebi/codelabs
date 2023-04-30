# List of supported regional service endpoints : https://cloud.google.com/vpc/docs/regional-service-endpoints
resource "google_compute_region_network_endpoint_group" "kms-neg" {
  name         = "kms-neg"
  region = var.region
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service = "europe-west1-cloudkms.googleapis.com"
}

resource "google_compute_region_backend_service" "kms-api" {
  name                            = "kms-api"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol = "HTTPS"
  backend {
    group = google_compute_region_network_endpoint_group.kms-neg.id

    # Empty otherwise you get the following message:
    # 'CONNECTION'. Balancing mode is not supported for Private Service Connect
    # network endpoint groups
    balancing_mode = ""
  }
}

resource "google_compute_region_url_map" "kms-api" {
  name        = "kms-map"
  default_service = google_compute_region_backend_service.kms-api.id
  host_rule {
    hosts        = ["europe-west1-cloudkms.${local.dns_name}"]
    path_matcher = "kms"
  }
  path_matcher {
    name            = "kms"
    default_service = google_compute_region_backend_service.kms-api.id
  }
}

resource "google_compute_region_target_http_proxy" "kms-api" {
  name    = "kms-api"
  url_map = google_compute_region_url_map.kms-api.id
  region = var.region
}

resource "google_compute_forwarding_rule" "kms-api" {
  name                  = "kms-api"
  load_balancing_scheme = "INTERNAL_MANAGED"
  network = google_compute_network.consumer.id
  subnetwork            = google_compute_subnetwork.consumer.id
  ip_address = google_compute_address.kms.address

  port_range            = "80"
  target                = google_compute_region_target_http_proxy.kms-api.id
}


resource "google_compute_address" "kms" {
  name = "kms"
  subnetwork = google_compute_subnetwork.consumer.id
  address_type = "INTERNAL"
}