variable "ssh_user" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "servers" {
  type = map(
    object({
      provider = string
      aws = object({
        region  = string
        compute = string
        lightsail = object({
          availability_zone = string
          blueprint_id      = string
          bundle_id         = string
        })
      })
      gc = object({
        compute = string
        gce = object({
          region       = string
          zone         = string
          machine_type = string
          image = object({
            project = string
            family  = string
          })
          enable_ipv6 = bool
        })
      })
    })
  )
  validation {
    condition = alltrue([
      for server in keys(var.servers) :
      length(server) <= 60 &&
      can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", server))
    ])
    error_message = "A server name must be 2 - 60 characters long and match [a-z][-a-z0-9]*[a-z0-9]."
  }
}

variable "google_cloud_project_id" {
  type    = string
  default = null
}
