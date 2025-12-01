variable "compute_instance" {
  type = object({
    name         = string
    region       = string
    full_zone    = string
    machine_type = string
    image = object({
      project = string
      family  = string
    })
  })
}

variable "ssh" {
  type = object({
    user       = string
    public_key = string
  })
}

variable "enable_ipv6" {
  type    = bool
  default = false
}
