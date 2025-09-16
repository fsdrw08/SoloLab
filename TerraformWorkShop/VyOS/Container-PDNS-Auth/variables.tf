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
    user        = optional(string)
    group       = optional(string)
    uid         = number
    gid         = number
    take_charge = optional(bool, false)
  })
}
