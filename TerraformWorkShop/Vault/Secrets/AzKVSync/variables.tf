variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "prov_azurerm" {
  description = "The AzureRM provider to use."
  type = object({
    subscription_id = string
  })
}

variable "kvv2_secrets" {
  type = list(object({
    mount        = string
    name         = string
    data_version = number
    secret_sets = list(object({
      key = string
      value_ref_az_kv = optional(object({
        key_vault_id = string
        name         = string
      }), null)
      value_string = optional(string, null)
    }))
  }))
  default = []
}