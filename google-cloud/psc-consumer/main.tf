terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.63.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# https://cloud.google.com/service-directory/docs/reference/rest
resource "google_project_service" "servicedirectory" {
  service = "servicedirectory.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns" {
  service = "dns.googleapis.com "
  disable_on_destroy = false
}



