variable "hyperv_host" {
  type    = string
  default = "127.0.0.1"
}

variable "hyperv_port" {
  type    = string
  default = 5986
}

variable "hyperv_user" {
  type = string
}

variable "hyperv_password" {
  type = string
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
