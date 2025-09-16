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
  type = list(object({
    bin_file_dir    = string
    bin_file_name   = string
    bin_file_source = string
  }))
  default = [
    {
      bin_file_dir    = "/usr/bin"
      bin_file_name   = "zot"
      bin_file_source = "https://github.com/project-zot/zot/releases/download/v2.1.8/zot-linux-amd64"
    }
  ]
}

variable "config" {
  type = object({
    create_dir = bool
    dir        = string
    main = object({
      basename = string
      content  = string
    })
    tls = optional(
      object({
        ca_basename   = optional(string, null)
        ca_content    = optional(string, null)
        cert_basename = string
        cert_content  = string
        key_basename  = string
        key_content   = string
        sub_dir       = string
      }),
      null
    )
  })
}
