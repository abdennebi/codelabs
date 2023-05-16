resource "google_compute_health_check" "www" {
  name                = "www"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/"
    port         = "80"
  }
}

resource "google_compute_instance_group_manager" "www" {

  for_each = var.zones

  base_instance_name = "www"

  name = "www-${each.value}"
  zone = each.value

  version {
    # Extract the region name from the zone name by removing the two last characters form the zone name
    # Example :
    #  ``substr("europe-west1-b", 0, length("europe-west1-b") - 2)`` gives ``europe-west1``
    instance_template = google_compute_instance_template.www[substr(each.value, 0, length(each.value) - 2)].self_link
  }



  target_size = 1
}
