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
    credential = optional(
      map(object({
        plaintext = optional(string, null)
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
          }),
          null
        )
      })),
      null
    )
  })
}

variable "data_sources" {
  type = list(object({
    iac_id            = string
    name              = string
    type              = string
    url               = string
    json_data_encoded = optional(map(any), null)
  }))
}

variable "dashboards" {
  type = list(object({
    template = string
    vars     = map(string)
  }))
}
