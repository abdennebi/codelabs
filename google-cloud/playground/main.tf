
variable "regions" {
  type = map(list(string))
  default = {
    "us-east1"    = ["us-east1-a"],
    "us-central1" = ["us-central1-a"],
    "us-west1"    = ["us-west1-a"],
  }
}

locals {
  flattened_regions = flatten([
    for region, zones in var.regions : [
      for zone in zones : {
        region = region
        zone   = zone
      }
    ]
  ])
}

output "flattened_regions" {
  value = local.flattened_regions
}