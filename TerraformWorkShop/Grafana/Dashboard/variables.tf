variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "prov_grafana" {
  type = object({
    url                  = string
    insecure_skip_verify = bool
    auth_plaintext       = optional(string, null)
    auth_reference = optional(object({
      vault_kvv2 = object({
        mount = string
        name  = string
        key   = string
      })
    }), null)
  })
}

variable "data_sources" {
  type = list(object({
    iac_id = string
    name   = string
    type   = string
    url    = string
  }))
}

variable "dashboards" {
  type = list(object({
    template = string
    vars     = map(string)
  }))
}
