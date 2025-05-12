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

variable "podman_quadlet" {
  type = object({
    dir = string
    files = list(object({
      template = string
      vars     = map(string)
    }))
    service = object({
      name   = string
      status = string
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
