variable "prov_etcd" {
  type = object({
    endpoints = string
    ca_cert   = string
    username  = string
    password  = string
    skip_tls  = bool
  })
}

variable "kv_pairs" {
  type = list(object({
    key   = string
    value = map(string)
  }))
}
