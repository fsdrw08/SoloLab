variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = optional(bool, false)
    token           = optional(string, null)
  })
}

variable "prov_gitea" {
  type = object({
    base_url    = string
    cacert_file = optional(string, null)
    insecure    = bool
    credential = optional(
      map(object({
        plaintext = optional(string, null)
        vault_kvv2 = optional(
          object({
            mount = string
            name  = string
            key   = string
          }),
          null
        )
      })),
      null
    )
  })
}