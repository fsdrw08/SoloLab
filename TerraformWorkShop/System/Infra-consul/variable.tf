variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}

variable "consul_post_process" {
  type = map(object({
    script_path = string
    vars        = optional(map(string))
  }))
}
