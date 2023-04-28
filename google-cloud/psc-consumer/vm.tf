resource "google_compute_instance" "consumer-test" {
  name         = "consumer-test"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.consumer.name
  }
}