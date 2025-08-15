variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "kvv2" {
  type = list(object({
    mount_path  = string
    description = optional(string, null)
    config = optional(object({
      max_versions         = optional(number, null)
      delete_version_after = optional(number, null)
      }), null
    )
  }))
}
