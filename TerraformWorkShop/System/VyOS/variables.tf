variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "consul" {
  type = object({
    install = object({
      zip_file_source = string
      zip_file_path   = string
      bin_file_dir    = string
    })
    init_script = object({
      file_source = string
      arguments   = optional(map(string))
    })
    config = object({
      file_source   = string
      file_path_dir = string
      vars          = optional(map(string))
    })
    service = object({
      status  = string
      enabled = bool
      systemd = object({
        file_source = string
        file_path   = string
        vars        = optional(map(string))
      })
    })
  })
}

variable "stepca" {
  type = object({
    install = object({
      tar_file_source = string
      tar_file_path   = string
      bin_file_dir    = string
    })
    init_script = object({
      file_source = string
      arguments   = optional(map(string))
    })
    config = object({
      file_source   = string
      file_path_dir = string
      vars          = optional(map(string))
    })
    service = object({
      status  = string
      enabled = bool
      systemd = object({
        file_source = string
        file_path   = string
        vars        = optional(map(string))
      })
    })
  })
}
variable "stepca_version" {
  type        = string
  description = "https://github.com/smallstep/certificates/releases"
  default     = "0.25.2"
}

variable "stepcli_version" {
  type        = string
  description = "https://github.com/smallstep/cli/releases"
  default     = "0.25.2"
}

variable "stepca_conf" {
  type = object({
    data_dir = string
    init = object({
      name             = string
      acme             = bool
      dns_names        = string
      ssh              = bool
      remote_mgmt      = bool
      provisioner_name = string
    })
    password    = string
    pwd_subpath = string
  })
}

variable "traefik_version" {
  type = string
}

variable "minio" {
  type = object({
    bin_file_source     = string
    systemd_file_source = string
    config_file_source  = string
  })
}
