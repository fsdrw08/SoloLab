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
      tls_value_sets = optional(
        object({
          value_ref = object({
            vault_kvv2 = optional(
              object({
                mount = string
                name  = string
                data_key = object({
                  ca          = string
                  cert        = string
                  private_key = string
                })
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
                data_key = object({
                  ca          = string
                  cert        = string
                  private_key = string
                })
              }),
              null
            )
          })
        }), null
      )
    })
    manifest_dest_path = string
  })
}

variable "podman_quadlet" {
  type = object({
    service = object({
      name   = string
      status = string
    })
    files = list(object({
      template = string
      vars     = map(string)
      dir      = string
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

variable "dns_record" {
  type = object({
    zone    = string
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  })
}
