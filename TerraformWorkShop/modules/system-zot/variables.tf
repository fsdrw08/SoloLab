variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "runas" {
  type = object({
    take_charge = optional(bool, false)
    user        = optional(string, null)
    uid         = optional(number, null)
    group       = optional(string, null)
    gid         = optional(number, null)
  })
}

variable "install" {
  type = object({
    server = object({
      bin_file_dir    = string
      bin_file_source = string
    })
    client = optional(object({
      bin_file_dir    = string
      bin_file_source = string
    }))
    oras = optional(object({
      tar_file_source = string
      tar_file_path   = string
      bin_file_dir    = string
    }))
  })
}

variable "config" {
  type = object({
    basename = string
    content  = string
    dir      = string
  })
}

variable "certs" {
  type = object({
    dir             = optional(string)
    cacert_basename = optional(string)
    cacert_content  = optional(string)
    cert_basename   = optional(string)
    cert_content    = optional(string)
    key_basename    = optional(string)
    key_content     = optional(string)
  })
}
