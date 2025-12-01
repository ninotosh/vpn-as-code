terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

locals {
  enable_ipv6 = var.enable_ipv6
  network     = local.enable_ipv6 ? google_compute_network.dual_stack[0].id : data.google_compute_network.single_stack.id
  subnetwork  = local.enable_ipv6 ? google_compute_subnetwork.dual_stack[0].id : null
}

data "google_compute_image" "this" {
  project = var.compute_instance.image.project
  family  = var.compute_instance.image.family
}

data "google_compute_network" "single_stack" {
  name = "default"
}

resource "google_compute_network" "dual_stack" {
  count = local.enable_ipv6 ? 1 : 0

  name                    = var.compute_instance.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "dual_stack" {
  count = local.enable_ipv6 ? 1 : 0

  name             = var.compute_instance.name
  network          = google_compute_network.dual_stack[0].id
  region           = var.compute_instance.region
  stack_type       = "IPV4_IPV6"
  ip_cidr_range    = "172.16.0.0/12"
  ipv6_access_type = "EXTERNAL"
}

resource "google_compute_address" "this" {
  name         = var.compute_instance.name
  region       = var.compute_instance.region
  network_tier = "STANDARD"
}

resource "google_compute_instance" "this" {
  boot_disk {
    initialize_params {
      image = data.google_compute_image.this.id
    }
  }
  can_ip_forward = true
  machine_type   = var.compute_instance.machine_type
  name           = var.compute_instance.name
  zone           = var.compute_instance.full_zone
  network_interface {
    network    = local.network
    subnetwork = local.subnetwork
    stack_type = local.enable_ipv6 ? "IPV4_IPV6" : "IPV4_ONLY"
    access_config {
      nat_ip       = google_compute_address.this.address
      network_tier = google_compute_address.this.network_tier
    }
    dynamic "ipv6_access_config" {
      for_each = local.enable_ipv6 ? [true] : []
      content {
        network_tier = "PREMIUM"
      }
    }
  }
  tags = [var.compute_instance.name]
  metadata = {
    ssh-keys = "${var.ssh.user}:${var.ssh.public_key}"
  }
}

resource "google_compute_firewall" "deny_all_ipv4" {
  name    = "${var.compute_instance.name}-deny-all-ipv4"
  network = local.network
  deny {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_ssh_ipv4" {
  priority = google_compute_firewall.deny_all_ipv4.priority - 1
  name     = "${var.compute_instance.name}-ssh"
  network  = local.network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_icmp_ipv4" {
  priority = google_compute_firewall.deny_all_ipv4.priority - 1
  name     = "${var.compute_instance.name}-icmp-ipv4"
  network  = local.network
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_tcp_ipv4" {
  priority = google_compute_firewall.deny_all_ipv4.priority - 1
  name     = "${var.compute_instance.name}-tcp-ipv4"
  network  = local.network
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_udp_ipv4" {
  priority = google_compute_firewall.deny_all_ipv4.priority - 1
  name     = "${var.compute_instance.name}-udp-ipv4"
  network  = local.network
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "deny_all_ipv6" {
  count = local.enable_ipv6 ? 1 : 0

  name    = "${var.compute_instance.name}-deny-all-ipv6"
  network = local.network
  deny {
    protocol = "all"
  }
  source_ranges = ["::/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_ssh_ipv6" {
  count = local.enable_ipv6 ? 1 : 0

  priority = google_compute_firewall.deny_all_ipv6[0].priority - 1
  name     = "${var.compute_instance.name}-ssh-ipv6"
  network  = local.network
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["::/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_icmp_ipv6" {
  count = local.enable_ipv6 ? 1 : 0

  priority = google_compute_firewall.deny_all_ipv6[0].priority - 1
  name     = "${var.compute_instance.name}-icmp-ipv6"
  network  = local.network
  allow {
    protocol = "58"
  }
  source_ranges = ["::/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_tcp_ipv6" {
  count = local.enable_ipv6 ? 1 : 0

  priority = google_compute_firewall.deny_all_ipv6[0].priority - 1
  name     = "${var.compute_instance.name}-tcp-ipv6"
  network  = local.network
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  source_ranges = ["::/0"]
  target_tags   = [var.compute_instance.name]
}

resource "google_compute_firewall" "allow_udp_ipv6" {
  count = local.enable_ipv6 ? 1 : 0

  priority = google_compute_firewall.deny_all_ipv6[0].priority - 1
  name     = "${var.compute_instance.name}-udp-ipv6"
  network  = local.network
  allow {
    protocol = "udp"
    ports    = ["53"]
  }
  source_ranges = ["::/0"]
  target_tags   = [var.compute_instance.name]
}
