variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "vyos_conn" {
  type = object({
    url = string
    key = string
  })
}

variable "runas" {
  type = object({
    user        = optional(string)
    group       = optional(string)
    uid         = number
    gid         = number
    take_charge = optional(bool, false)
  })
}

variable "data_dirs" {
  type = string
}

variable "config" {
  type = object({
    basename     = string
    content_yaml = string
    dir          = string
  })
}

variable "certs" {
  type = object({
    dir                         = string
    cert_content_tfstate_ref    = string
    cert_content_tfstate_entity = string
    cacert_basename             = string
    cert_basename               = string
    key_basename                = string
  })
}

variable "container" {
  type = object({
    network = object({
      create      = bool
      name        = string
      cidr_prefix = optional(string)
      address     = string
    })
    workload = object({
      name        = string
      image       = string
      local_image = optional(string, null)
      others      = map(string)
    })
  })
}

variable "reverse_proxy" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}

variable "dns_record" {
  type = object({
    host = string
    ip   = string
  })
}
