variable "hyperv" {
  type = object({
    host     = string
    port     = number
    user     = string
    password = string
  })
  default = {
    host     = "127.0.0.1"
    port     = 5986
    user     = "root"
    password = "P@ssw0rd"
  }
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_name" {
  type    = string
  default = null
}

variable "vhd_dir" {
  type    = string
  default = "C:\\ProgramData\\Microsoft\\Windows\\Virtual Hard Disks"
}

variable "source_disk" {
  type    = string
  default = null
}

variable "fcos_timezone" {
  type = string
}
