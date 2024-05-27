variable "boot_command" {
  type    = list(string)
}

variable "configuration_version" {
  type    = string
  default = "8.0"
}

variable "disk_size" {
  type    = string
  default = "128000"
}

variable "disk_additional_size" {
  type    = list(number)
  default = ["1024"]
}

variable "cd_files" {
  type    = list(string)
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "iso_checksum" {
  type    = string
  default = ""
}

variable "iso_checksum_type" {
  type    = string
  default = "none"
}

variable "iso_url" {
  type    = string
  default = ""
}

variable "output_directory" {
  type    = string
  default = ""
}

variable "output_vagrant" {
  type    = string
  default = ""
}

variable "ssh_username" {
  type    = string
  default = ""
}

variable "ssh_password" {
  type    = string
  default = ""
}

variable "switch_name" {
  type    = string
  default = ""
}

variable "mac_address" {
  type    = string
  default = ""
}

variable "vagrantfile_template" {
  type    = string
  default = ""
}

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}