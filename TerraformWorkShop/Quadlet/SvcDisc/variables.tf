variable "server" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}
