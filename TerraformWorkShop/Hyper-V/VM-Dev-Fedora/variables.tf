variable "provider_hyperv" {
  type = object({
    user     = string
    password = string
    host     = string
    port     = number
  })
  # default = {
  #   user     = "root"
  #   password = "P@ssw0rd"
  #   host     = "127.0.0.1"
  #   port     = 5986
  # }
}


variable "vm_name" {
  type    = string
  default = null
}

variable "source_disk" {
  type    = string
  default = null
}

variable "data_disk_path" {
  type    = string
  default = "value"
}
