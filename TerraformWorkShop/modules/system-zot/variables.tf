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

