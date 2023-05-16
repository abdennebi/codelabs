variable "project_id" {
  type = string
}

variable "regions" {
  type    = set(string)
  default = ["us-east1", "us-central1", "us-west1"]
}

variable "zones" {
  type    = set(string)
  default = ["us-east1-b", "us-central1-a", "us-west1-a"]
}

variable "subnetworks" {
  type = map(map(string))
  default = {
    "us-east1" = {
      "cidr" = "10.1.0.0/24"
    }
    "us-central1" = {
      "cidr" = "10.2.0.0/24"
    }
    "us-west1" = {
      "cidr" = "10.3.0.0/24"
    }
  }
}

variable "instance_type" {
  type    = string
  default = "e2-micro"
}
