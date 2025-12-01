provider "google" {
  project = var.google_cloud_project_id
}

module "google" {
  source = "./modules/google"
  for_each = {
    for k, v in var.servers :
    k => v.gc.gce
    if alltrue([
      v.provider == "gc",
      try(v.gc.compute, "") == "gce"
    ])
  }
  compute_instance = {
    name         = each.key
    region       = "${each.value.region}"
    full_zone    = "${each.value.region}-${each.value.zone}"
    machine_type = each.value.machine_type
    image        = each.value.image
  }
  ssh = {
    user       = var.ssh_user
    public_key = var.ssh_public_key
  }
  enable_ipv6 = each.value.enable_ipv6
}

output "gc" {
  value = module.google
}
