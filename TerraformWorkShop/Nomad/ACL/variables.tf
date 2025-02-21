variable "prov_nomad" {
  type = object({
    address     = string
    skip_verify = bool
  })
}

# variable "NOMAD_TOKEN" {
#   type = string
# }

variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

