variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "prov_remote" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "podman_kube" {
  type = object({
    helm = object({
      name       = string
      chart      = string
      value_file = string
      value_sets = optional(
        list(
          object({
            name                = string
            value_string        = optional(string, null)
            value_template_path = optional(string, null)
            value_template_vars = optional(map(string), null)
          })
        ), null
      )
      tls = optional(
        object({
          value_sets = list(
            object({
              name          = string
              value_ref_key = string
            })
          )
          vault_kvv2 = optional(
            object({
              mount = string
              name  = string
            }),
            null
          )
          tfstate = optional(
            object({
              backend = object({
                type   = string
                config = map(string)
              })
              cert_name = string
            }),
            null
          )
        }), null
      )
    })
    manifest_dest_path = string
  })
}

variable "podman_quadlet" {
  type = object({
    dir = string
    units = list(object({
      files = list(object({
        template = string
        vars     = map(string)
      }))
      service = optional(
        object({
          name   = string
          status = string
        }),
        null
      )
    }))
  })
}

variable "prov_pdns" {
  type = object({
    api_key        = string
    server_url     = string
    insecure_https = optional(bool, null)
  })
}

variable "dns_records" {
  type = list(object({
    zone    = string
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}
