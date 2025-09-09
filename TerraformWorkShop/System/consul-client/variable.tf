variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
    sudo     = bool
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

variable "XDG_CONFIG_HOME" {
  type = string
}

variable "bin_dir" {
  type = string
}

variable "data_dir" {
  type = string
}
