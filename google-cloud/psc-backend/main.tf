provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_id" "rnd" {
  byte_length = 4
}

locals {
  dns_name = "${random_id.rnd.hex}.com."
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "servicedirectory" {
  service = "servicedirectory.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  service = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "kms" {
  service = "cloudkms.googleapis.com"
  disable_on_destroy = false
}
