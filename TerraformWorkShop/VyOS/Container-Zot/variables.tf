variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "prov_vyos" {
  type = object({
    url = string
    key = string
  })
}

variable "runas" {
  type = object({
    user        = string
    group       = string
    uid         = number
    gid         = number
    take_charge = bool
  })
}
