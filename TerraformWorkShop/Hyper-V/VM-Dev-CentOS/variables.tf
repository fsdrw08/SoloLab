variable "hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
  default = {
    host     = "127.0.0.1"
    port     = 5986
    user     = "root"
    password = "P@ssw0rd"
  }
}

variable "vm_name" {
  type    = string
  default = null
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vhd_dir" {
  type    = string
  default = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
}

variable "source_disk" {
  type    = string
  default = null
}

variable "network_adaptors" {
  type = list(object({
    name                = string
    switch_name         = string
    dynamic_mac_address = optional(bool)
    static_mac_address  = optional(string)
  }))
}

variable "enable_secure_boot" {
  type    = string
  default = "Off"
}

variable "cloudinit" {
  type = object({
    meta_data = object({
      file_source = string
      vars        = map(string)
    })
    user_data = object({
      file_source = string
      vars        = map(string)
    })
    network_config = object({
      file_source = string
      vars        = map(list(string))
    })
  })
}

variable "memory_startup_bytes" {
  type    = number
  default = 1023410176
}

variable "memory_maximum_bytes" {
  type    = number
  default = 2147483648
}

variable "memory_minimum_bytes" {
  type    = number
  default = 1023410176
}
