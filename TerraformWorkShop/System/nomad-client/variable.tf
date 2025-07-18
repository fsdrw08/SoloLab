variable "prov_system" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}
