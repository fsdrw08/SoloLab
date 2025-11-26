variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "prov_grafana" {
  type = object({
    url                  = string
    auth                 = string
    insecure_skip_verify = optional(bool, true)
  })
}
