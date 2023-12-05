variable "server" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "user" {
  type = map(object({
    name     = string
    password = string
  }))
}
