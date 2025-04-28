variable "pdns" {
  type = object({
    api_key        = string
    server_url     = string
    insecure_https = optional(bool, null)
  })
}

variable "zones" {
  type = list(object({
    name        = string
    nameservers = list(string)
    records = list(object({
      fqdn    = string
      type    = string
      ttl     = number
      results = list(string)
    }))
  }))
}
