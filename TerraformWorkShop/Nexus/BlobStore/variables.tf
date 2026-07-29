variable "prov_vault" {
  type = object({
    address         = string
    skip_tls_verify = bool
    token           = optional(string, null)
  })
}

variable "prov_sonatyperepo" {
  type = object({
    url = string
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

variable "blob_store_s3" {
  type = object({
    name = string
    bucket = object({
      name   = string
      prefix = optional(string, null)
      region = string
    })
    advanced_bucket_connection = optional(
      object({
        endpoint                 = string
        force_path_style         = bool
        max_connection_pool_size = optional(number, null)
        signer_type              = optional(string, null)
      }),
      null
    )
    bucket_security = map(object({
      plaintext = optional(string, null)
      vault_kvv2 = optional(
        object({
          mount = string
          name  = string
          key   = string
        }),
        null
      )
    }))
    soft_quota = optional(object({
      limit = optional(number, null)
      type  = string
    }), null)
  })
}

