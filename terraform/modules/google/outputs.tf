output "ipv4_address" {
  value = google_compute_address.this.address
}

output "ipv6_address" {
  value = local.enable_ipv6 ? google_compute_instance.this.network_interface[0].ipv6_access_config[0].external_ipv6 : null
}
