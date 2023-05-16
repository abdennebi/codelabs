resource "google_service_account" "www" {
  account_id = "www-sa"
}

resource "google_compute_instance_template" "www" {
  for_each = var.regions

  name             = "instance-template-${each.value}"
  description      = "Instance Template in ${each.value}"
  machine_type     = var.instance_type
  can_ip_forward   = false
  region           = each.value
  min_cpu_platform = null
  tags             = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.www.self_link
    subnetwork = google_compute_subnetwork.www[each.value].self_link
  }

  metadata_startup_script = <<EOF
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
  EOF

  service_account {
    email = google_service_account.www.email
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    scopes = ["cloud-platform"]
  }
}

