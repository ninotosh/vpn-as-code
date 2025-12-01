variable "lightsail" {
  type = object({
    name              = string
    availability_zone = string
    blueprint_id      = string
    bundle_id         = string
  })
}

variable "ssh_public_key" {
  type = string
}
