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
    name        = string
    cidr_prefix = string
  })
  default = null
}

variable "workloads" {
  type = list(object({
    name        = string
    image       = string
    local_image = optional(string, "")
    pull_flag   = optional(string, "")
    others      = map(string)
  }))
}
