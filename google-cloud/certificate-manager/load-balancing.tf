resource "google_compute_global_address" "app" {
  name        = "app-lb-ip"
}


#resource "google_compute_global_forwarding_rule" "app_https" {
#  name        = "app_https"
#  ip_address  = google_compute_global_address.app.id
#  port_range  = "443"
#  target      = google_compute_target_https_proxy.app.self_link
#}
#
#resource "google_compute_global_forwarding_rule" "app_http" {
#  name        = "app_http"
#  ip_address  = google_compute_global_address.app.id
#  port_range  = "80"
#  target      = google_compute_target_http_proxy.app.self_link
#}

#resource "google_compute_target_https_proxy" "app" {
#  name            = "app"
#  url_map         = google_compute_url_map.app.self_link
#  certificate_map = "//${google_project_service.certificatemanager.service}/${google_certificate_manager_certificate_map.app.id}"
#}
#
#
#resource "google_compute_target_http_proxy" "app" {
#  name        = "app"
#  url_map     = google_compute_url_map.app.self_link
#}
#
### Default URL map
#resource "google_compute_url_map" "default" {
#  name        = "default"
#}
#
## Redirect URL map
#resource "google_compute_url_map" "app" {
#  name        = "app"
#
#  default_url_redirect {
#    https_redirect         = true
#    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
#    strip_query            = false
#  }
#}