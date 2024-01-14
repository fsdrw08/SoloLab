variable "boot_command" {
  type    = list(string)
}

variable "configuration_version" {
  type    = string
  default = ""
}

variable "disk_size" {
  type    = string
  default = "70000"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "cpus" {
  type    = string
  default = "2"
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

variable "cd_files" {
  type    = list(string)
}

variable "cd_label" {
  type    = string
  default = "cidata"
}

variable "output_directory" {
  type    = string
  default = ""
}

variable "provision_script_options" {
  type    = string
  default = ""
}

// variable "output_vagrant" {
//   type    = string
//   default = ""
// }

variable "ssh_password" {
  type    = string
  default = ""
  sensitive = true
}

variable "switch_name" {
  type    = string
  default = ""
}

// variable "vagrantfile_template" {
//   type    = string
//   default = ""
// }

variable "vlan_id" {
  type    = string
  default = ""
}

variable "vm_name" {
  type    = string
  default = ""
}