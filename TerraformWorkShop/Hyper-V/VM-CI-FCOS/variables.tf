variable "prov_hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_vault" {
  type = object({
    schema          = string
    address         = string
    token           = string
    skip_tls_verify = bool
  })
}

variable "vm" {
  type = object({
    count     = number
    base_name = string
    vhd = object({
      dir    = string
      source = string
      data_disk_tfstate = optional(
        object({
          backend = object({
            type   = string
            config = map(string)
          })
        }), null
      )
    })
    nic = list(object({
      name                = string
      switch_name         = string
      dynamic_mac_address = optional(bool, null)
      static_mac_address  = optional(string, null)
    }))
    enable_secure_boot = optional(string, "On")
    power_state        = optional(string, "Off")
    memory = object({
      static        = optional(bool, null)
      dynamic       = optional(bool, null)
      startup_bytes = number
      maximum_bytes = number
      minimum_bytes = number
    })
  })
}

variable "butane" {
  type = object({
    files = object({
      base   = string
      others = optional(list(string), null)
    })
    # vars = map(string)
    vars = object({
      global = map(string)
      local  = optional(list(map(string)), null)
      value_refers = optional(
        list(object({
          vault_kvv2 = optional(
            object({
              mount = string
              name  = string
            }),
            null
          )
          tfstate = optional(
            object({
              backend = object({
                type   = string
                config = map(string)
              })
              cert_name = string
            }),
            null
          )
          value_sets = list(
            object({
              name          = string
              value_ref_key = string
            })
          )
        })),
        null
      )
    })
  })
}

