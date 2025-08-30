variable "prov_etcd" {
  type = object({
    endpoints = string
    ca_cert   = optional(string, null)
    username  = string
    password  = string
    skip_tls  = bool
  })
}

variable "kv_pairs" {
  type = list(object({
    path     = optional(string, "/skydns")
    hostname = string
    value = object({
      string_map = map(string)
      number_map = map(number)
    })
  }))
}
