resource "google_certificate_manager_dns_authorization" "app" {
  name        = "app"
  domain      = var.domain
}

resource "google_certificate_manager_certificate" "app" {
  name        = "app"
  managed {
    domains = [var.domain, "*.${var.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.app.id
    ]
  }
}

resource "google_certificate_manager_certificate_map" "app" {
  name        = "app"
}

resource "google_certificate_manager_certificate_map_entry" "app" {
  name         = "app"
  map          = google_certificate_manager_certificate_map.app.name
  certificates = [google_certificate_manager_certificate.app.id]
  hostname     = var.domain

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_certificate_manager_certificate_map_entry" "app_wildcard" {
  name         = "wildcard"
  map          = google_certificate_manager_certificate_map.app.name
  certificates = [google_certificate_manager_certificate.app.id]
  hostname     = "*.${var.domain}"

  lifecycle {
    prevent_destroy = true
  }
}