output "ipv4_address" {
  value = aws_lightsail_static_ip.this.ip_address
}

output "ipv6_address" {
  value = aws_lightsail_instance.this.ipv6_addresses.0
}

output "region" {
  value = data.aws_region.this.region
}
