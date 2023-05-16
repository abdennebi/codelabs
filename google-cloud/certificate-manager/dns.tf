
resource "google_dns_managed_zone" "app" {
  name        = "app"
  dns_name    = "c.${var.domain}."

  lifecycle {
    prevent_destroy = true
  }
}


## Global load balancer DNS records ##
resource "google_dns_record_set" "app_sub_domain" {
  managed_zone = google_dns_managed_zone.app.name
  name         = "*.${google_dns_managed_zone.app.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_global_address.app.address]
}

resource "google_dns_record_set" "app_top_level_domain" {
  managed_zone = google_dns_managed_zone.app.name
  name         = google_dns_managed_zone.app.dns_name
  type         = "A"
  rrdatas      = [google_compute_global_address.app.address]
}

resource "google_dns_record_set" "dns_authorization_wildcard_certificate" {
  name         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].name
  managed_zone = google_dns_managed_zone.app.name
  type         = google_certificate_manager_dns_authorization.app.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.app.dns_resource_record[0].data]
}