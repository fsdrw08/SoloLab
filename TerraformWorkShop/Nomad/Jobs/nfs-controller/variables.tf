variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}
