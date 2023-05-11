locals {
  tag_allow_iap = "allow-iap"
  tag_allow_healthcheck = "allow-healthcheck"
}


resource "google_compute_instance" "www_01" {
  name         = "www-01"
  machine_type = "e2-medium"
  zone         = var.region_1_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.region_1.name
  }

  tags = [local.tag_allow_healthcheck]

  metadata_startup_script = <<EOT
  #! /bin/bash
  apt-get update
  apt-get install apache2 -y
  a2ensite default-ssl
  a2enmod ssl
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Page served from: $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2
  EOT
}

resource "google_compute_instance" "www_02" {
  name         = "www-02"
  machine_type = "e2-medium"
  zone         = var.region_2_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  tags = [local.tag_allow_healthcheck]

  network_interface {
    subnetwork = google_compute_subnetwork.region_2.name
  }

  metadata_startup_script = <<EOT
  #! /bin/bash
  apt-get update
  apt-get install apache2 -y
  a2ensite default-ssl
  a2enmod ssl
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  echo "Page served from: $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2
  EOT
}

resource "google_compute_instance_group" "ig-www-region1" {
  name = "ig-www-${var.region_1}"
  zone = var.region_1_zone
  instances = [
    google_compute_instance.www_01.id,
  ]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "ig-www-region2" {
  name = "ig-www-${var.region_2}"
  zone = var.region_2_zone
  instances = [
    google_compute_instance.www_02.id,
  ]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance" "client" {
  name         = "client"
  machine_type = "e2-medium"
  zone         = var.region_1_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.region_1.name
  }

  tags = [local.tag_allow_iap]


  metadata_startup_script = <<EOT
  #! /bin/bash
  apt-get update
  apt-get install dnsutils -y
  EOT
}