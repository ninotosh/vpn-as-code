terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_lightsail_key_pair" "this" {
  public_key = var.ssh_public_key
}

resource "aws_lightsail_instance" "this" {
  name              = var.lightsail.name
  availability_zone = var.lightsail.availability_zone
  blueprint_id      = var.lightsail.blueprint_id
  bundle_id         = var.lightsail.bundle_id
  key_pair_name     = aws_lightsail_key_pair.this.name
}

resource "aws_lightsail_static_ip" "this" {
  name = "${var.lightsail.name}-static-ip"
}

resource "aws_lightsail_static_ip_attachment" "this" {
  instance_name  = aws_lightsail_instance.this.name
  static_ip_name = aws_lightsail_static_ip.this.name
}

resource "aws_lightsail_instance_public_ports" "this" {
  instance_name = aws_lightsail_instance.this.name
  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
  port_info {
    protocol  = "udp"
    from_port = 53
    to_port   = 53
  }
  port_info {
    protocol  = "icmp"
    from_port = -1
    to_port   = -1
  }
  port_info {
    protocol  = "icmpv6"
    from_port = -1
    to_port   = -1
  }
}

data "aws_region" "this" {}
