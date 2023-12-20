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
    bin_file_source    = string
    init_script_source = optional(string)
    config_file_source = string
    config_file_vars = object({
      data_dir        = string
      client_addr     = string
      token_init_mgmt = string
    })
    config_file_vars_others = optional(map(string))
    systemd_file_source     = string
    systemd_file_vars = object({
      user  = string
      group = string
    })
    systemd_file_vars_others = optional(map(string))
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
