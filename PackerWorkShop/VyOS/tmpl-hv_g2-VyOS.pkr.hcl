variable "ansible_override" {
  type    = string
  default = ""
}

variable "boot_command" {
  type    = list(string)
}

variable "configuration_version" {
  type    = string
  default = ""
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

// https://github.com/hashicorp/packer-plugin-hyperv/issues/65
// packer {
//   required_plugins {
//     hyperv = {
//       version = ">= 1.0.4"
//       source  = "github.com/hashicorp/hyperv"
//     }
//   }
// }

source "hyperv-iso" "vm" {
  boot_command          = "${var.boot_command}"
  boot_wait             = "2s"
  communicator          = "none"
  configuration_version = "${var.configuration_version}"
  cpus                  = "${var.cpus}"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = false
  generation            = 2
  guest_additions_mode  = "disable"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  // https://www.packer.io/plugins/builders/hyperv/iso#cd_files
  // https://wiki.debian.org/CDDVD
  cd_files              = "${var.cd_files}"
  memory                = "${var.memory}"
  output_directory      = "${var.output_directory}"
  skip_export           = true
  // https://www.packer.io/plugins/builders/hyperv/iso#disable_shutdown
  shutdown_command      = "sudo shutdown now"
  shutdown_timeout      = "30m"
  // ssh_username          = "${var.ssh_username}"
  // ssh_password          = "${var.ssh_password}"
  // ssh_timeout           = "4h"
  switch_name           = "${var.switch_name}"
  // Vyos identify the nic by mac address
  // In oder fix the relationship between NIC and switch (e.g. eth0 for WAN, forever), 
  // we need to bind MAC address to the NIC (eth0 by default), 
  // if we dont bind the mac address to NIC, the vyos Hyper-V VM (vagrant) instance will have different MAC address each time (when run `vagrant up`)
  // which means the WAN switch will connect to eth1 after the instance get created
  // if you want to change this mac address, also change in ../vagrant-VyOS$version line 20
  // update: already improved the provision process, now nic hw-id will be reset at the end of the provision process
  // mac_address           = "0000deadbeef"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.vm"]
  //   post-processor "vagrant" {
  //   keep_input_artifact  = true
  //   output               = "${var.output_vagrant}"
  //   vagrantfile_template = "${var.vagrantfile_template}"
  // }
}
