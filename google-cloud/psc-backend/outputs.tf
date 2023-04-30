output "router" {
  value       = "${var.region}.${local.dns_name}"
  description = "The KMS service dns"
}