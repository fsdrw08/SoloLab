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

variable "certs" {
  type = object({
    dir                         = string
    cert_content_tfstate_ref    = string
    cert_content_tfstate_entity = string
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
      local_image = optional(string, "")
      pull_flag   = optional(string, "")
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
