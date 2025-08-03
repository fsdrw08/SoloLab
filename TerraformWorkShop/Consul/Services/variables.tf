variable "prov_consul" {
  type = object({
    scheme         = string
    address        = string
    datacenter     = string
    token          = string
    insecure_https = bool
  })
}

variable "nodes" {
  type = list(object({
    name    = string
    address = string
  }))
}

variable "services" {
  type = list(object({
    name                = string
    node                = string
    datacenter          = optional(string)
    namespace           = optional(string)
    address             = optional(string)
    port                = optional(string)
    service_id          = optional(string)
    enable_tag_override = optional(string)
    check = optional(list(object({
      check_id                          = string
      interval                          = string
      name                              = string
      timeout                           = string
      deregister_critical_service_after = optional(number, null)
      header = optional(list(object(
        {
          name  = string
          value = list(string)
        }
      )), [])
      http            = optional(string, null)
      method          = optional(string, null)
      notes           = optional(string, null)
      status          = optional(string, null)
      tcp             = optional(string, null)
      tls_skip_verify = optional(bool, null)
    })), null)
    meta = optional(map(string), null)
    tags = optional(list(string), [])
  }))
}
