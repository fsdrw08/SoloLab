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
      name              = string
      region            = string
      access_key_id     = string
      secret_access_key = string
    })
    soft_quota = optional(object({
      limit = number
      type  = string
    }), null)
  })
}

variable "roles" {
  type = list(object({
    name       = string
    roleid     = string
    privileges = list(string)
  }))
}
