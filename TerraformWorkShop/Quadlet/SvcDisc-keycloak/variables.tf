variable "prov_remote" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "certs_ref" {
  type = object({
    tfstate = optional(
      object({
        backend = string
        config  = map(string)
        entity  = string
      }), null
    )
    config_node = object({
      cert = string
      key  = string
    })

  })
}

variable "podman_kube" {
  type = object({
    helm = object({
      name       = string
      chart      = string
      value_file = string
      value_sets = optional(
        list(object({
          name                = string
          value_string        = optional(string, null)
          value_template_path = optional(string, null)
          value_template_vars = optional(map(string), null)
      })), null)
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
