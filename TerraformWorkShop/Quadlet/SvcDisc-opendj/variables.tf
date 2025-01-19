variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "certs" {
  type = object({
    cert_content_tfstate_ref    = string
    cert_content_tfstate_entity = string
  })
}

variable "podman_kube" {
  type = object({
    helm = object({
      name       = string
      chart      = string
      value_file = string
      value_sets = list(object({
        name                = string
        value_string        = optional(string, null)
        value_template_path = optional(string, null)
        value_template_vars = optional(map(string), null)
      }))
    })
    yaml_file_path = string
  })
}

variable "podman_quadlet" {
  type = object({
    service = object({
      name   = string
      status = string
    })
    quadlet = object({
      file_contents = list(object({
        file_source = string
        # https://stackoverflow.com/questions/63180277/terraform-map-with-string-and-map-elements-possible
        vars = map(string)
      }))
      file_path_dir = string
    })
  })
}

variable "container_restart" {
  type = object({
    systemd_path_unit = object({
      content = object({
        templatefile = string
        vars         = map(string)
      })
      path = string
    })
    systemd_service_unit = object({
      content = object({
        templatefile = string
        vars         = map(string)
      })
      path = string
    })
  })
}

variable "pdns" {
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
