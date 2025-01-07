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
      data_disk_ref = optional(
        object({
          backend = string
          config  = map(string)
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
    memory = object({
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
