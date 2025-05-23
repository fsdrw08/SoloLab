variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
}


variable "network" {
  type = object({
    create      = bool
    name        = string
    cidr_prefix = optional(string)
  })
}

variable "workload" {
  type = object({
    name        = string
    image       = string
    local_image = optional(string, "")
    pull_flag   = optional(string, "")
    others      = map(string)
  })
}
