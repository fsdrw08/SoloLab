variable "vault_conn" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}
