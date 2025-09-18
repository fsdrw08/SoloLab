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

variable "owner" {
  type = object({
    uid = number
    gid = number
  })
}
