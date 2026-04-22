variable "prov_nexus" {
  type = object({
    insecure = bool
    url      = string
    username = string
    password = string
  })
}

variable "prov_vault" {
  type = object({
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "blob_store_s3" {
  type = object({
    name = string
    bucket = object({
      name       = string
      region     = string
      expiration = number
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
    bucket_security_value_refers = list(object({
      value_sets = list(
        object({
          name          = string
          value_ref_key = string
        })
      )
      vault_kvv2 = optional(
        object({
          mount = string
          name  = string
        }),
        null
      )
    }))
    soft_quota = optional(object({
      limit = number
      type  = string
    }), null)
  })
}

