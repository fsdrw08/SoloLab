variable "ansible_override" {
  type    = string
  default = ""
}

variable "boot_command" {
  type    = list(string)
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

variable "provision_script_options" {
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

source "hyperv-iso" "vm" {
  boot_command          = "${var.boot_command}"
  boot_wait             = "2s"
  communicator          = "ssh"
  cpus                  = "${var.cpus}"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  configuration_version = "8.0"
  guest_additions_mode  = "disable"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  cd_files              = "${var.cd_files}"
  memory                = "${var.memory}"
  output_directory      = "${var.output_directory}"
  shutdown_command      = "sudo shutdown now"
  shutdown_timeout      = "30m"
  ssh_username          = "${var.ssh_username}"
  ssh_password          = "${var.ssh_password}"
  ssh_timeout           = "4h"
  switch_name           = "${var.switch_name}"
  // if you want to change this mac address, also change in ../Vagrant/hv_vyos130_g2.tpl line 20
  mac_address           = "0000deadbeef"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.vm"]
    post-processor "vagrant" {
    keep_input_artifact  = true
    output               = "${var.output_vagrant}"
    vagrantfile_template = "${var.vagrantfile_template}"
  }
}
