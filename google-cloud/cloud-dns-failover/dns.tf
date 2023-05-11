# create the private zone and a DNS record set with the failover routing policy.

resource "random_id" "rnd" {
  byte_length = 4
}

locals {
  dns_name = "${random_id.rnd.hex}.com."
}

resource "google_dns_managed_zone" "app" {
  name       = "app"
  dns_name   = local.dns_name
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.app.id
    }
  }
}

resource "google_dns_record_set" "app" {
  name         = "app.${var.region_1}.${local.dns_name}"
  managed_zone = google_dns_managed_zone.app.name
  type         = "A"
  ttl          = 5

  routing_policy {
    primary_backup {
      #  Always send a given percentage of the traffic to the failover targets, regardless of the health check status of the primary targets.
      trickle_ratio = 0.1

      primary {
        internal_load_balancers {
          load_balancer_type = "regionalL4ilb"
          ip_address         = google_compute_address.lb_ip_region1.address
          ip_protocol        = "tcp"
          network_url        = google_compute_network.app.id
          port               = "80"
          project            = var.project_id
          region             = var.region_1

        }
      }

      backup_geo {
        location = var.region_1
        health_checked_targets {
          internal_load_balancers {
            load_balancer_type = "regionalL4ilb"
            ip_address         = google_compute_address.lb_ip_region1.address
            ip_protocol        = "tcp"
            network_url        = google_compute_network.app.id
            port               = "80"
            project            = var.project_id
            region             = var.region_1
          }
        }
      }

      backup_geo {
        location = var.region_2
        health_checked_targets {
          internal_load_balancers {
            load_balancer_type = "regionalL4ilb"
            ip_address         = google_compute_address.lb_ip_region2.address
            ip_protocol        = "tcp"
            network_url        = google_compute_network.app.id
            port               = "80"
            project            = var.project_id
            region             = var.region_2
          }
        }
      }
    }
  }

  depends_on = [google_compute_forwarding_rule.region1, google_compute_forwarding_rule.region2]
}