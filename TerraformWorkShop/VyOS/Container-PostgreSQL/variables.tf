variable "vm_conn" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
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

variable "data_dirs" {
  type        = string
  description = "the data dir to store cockroachdb data"
}

variable "container_postgresql" {
  type = object({
    network = object({
      create      = bool
      name        = optional(string)
      cidr_prefix = optional(string)
    })
    workload = object({
      name        = string
      image       = string
      local_image = optional(string, null)
      others      = map(string)
    })
  })
}

variable "container_adminer" {
  type = object({
    network = object({
      create      = bool
      name        = optional(string)
      cidr_prefix = optional(string)
    })
    workload = object({
      name        = string
      image       = string
      local_image = optional(string, null)
      others      = map(string)
    })
  })
}

variable "reverse_proxy" {
  type = map(object({
    path    = string
    configs = map(string)
  }))
}

variable "dns_records" {
  type = list(object({
    host = string
    ip   = string
  }))
}
