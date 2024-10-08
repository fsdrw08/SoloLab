variable "vm_name" {
  type    = string
  default = null
}

variable "cloudinit_nocloud" {
  type = list(object({
    content_source = string
    content_vars   = map(string)
    filename       = string
  }))
  default = null
}
