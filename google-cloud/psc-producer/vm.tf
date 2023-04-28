resource "google_compute_instance" "www_01" {
  name         = "www-01"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.producer_euw1.name
  }

  metadata_startup_script = <<EOT
  #! /bin/bash
  apt-get update
  apt-get install tcpdump -y
  apt-get install apache2 -y
  a2ensite default-ssl
  apt-get install iperf3 -y
  a2enmod ssl
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  filter="{print \$NF}"
  echo "Page on $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2
  iperf3 -s -p 5050
  EOT
}

resource "google_compute_instance" "www_02" {
  name         = "www-02"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.producer_euw1.name
  }

  metadata_startup_script = <<EOT
  #! /bin/bash
  apt-get update
  apt-get install tcpdump -y
  apt-get install apache2 -y
  a2ensite default-ssl
  apt-get install iperf3 -y
  a2enmod ssl
  vm_hostname="$(curl -H "Metadata-Flavor:Google" \
  http://169.254.169.254/computeMetadata/v1/instance/name)"
  filter="{print \$NF}"
  echo "Page on $vm_hostname" | \
  tee /var/www/html/index.html
  systemctl restart apache2
  iperf3 -s -p 5050
  EOT
}

resource "google_compute_instance_group" "www" {
  name = "ig-www"
  zone = var.zone
  instances = [
    google_compute_instance.www_01.id,
    google_compute_instance.www_02.id,
  ]

  named_port {
    name = "http"
    port = "80"
  }
}