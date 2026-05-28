variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = optional(bool, false)
    token           = optional(string, null)
  })
}

variable "prov_tfe" {
  type = object({
    hostname        = optional(string, "app.terraform.io")
    ssl_skip_verify = bool
    token_plaintext = optional(string, null)
    token_reference = optional(
      object({
        vault_kvv2 = object({
          mount = string
          name  = string
          key   = string
        })
    }), null)
  })
}

variable "organizations" {
  type = list(object({
    iac_id = string
    name   = string
    email  = string
  }))
}

variable "workspaces" {
  type = list(object({
    iac_id       = string
    name         = string
    organization = string
  }))
}
