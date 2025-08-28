variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
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
