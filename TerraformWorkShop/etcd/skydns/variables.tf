variable "prov_etcd" {
  type = object({
    endpoints = string
    ca_cert   = optional(string, null)
    username  = string
    password  = string
    skip_tls  = bool
  })
}

variable "dns_records" {
  type = list(object({
    path     = optional(string, "/skydns")
    hostname = string
    value = object({
      string_map = map(string)
      number_map = map(number)
    })
  }))
}
