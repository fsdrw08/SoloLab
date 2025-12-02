variable "hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
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
    checkpoint_type    = optional(string, "Disabled")
    processor_count    = optional(number, 2)
    memory = object({
      static        = optional(bool, null)
      dynamic       = optional(bool, null)
      startup_bytes = number
      maximum_bytes = number
      minimum_bytes = number
    })
  })
}

variable "cloudinit_nocloud" {
  type = list(object({
    content_source = string
    content_vars   = map(string)
    filename       = string
  }))
  default = null
}
