// https://github.com/hashicorp/packer-plugin-hyperv/issues/65
packer {
  required_plugins {
    hyperv = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

source "hyperv-iso" "vm" {
  boot_command          = "${var.boot_command}"
  boot_wait             = "5s"
  communicator          = "none"
  configuration_version = "${var.configuration_version}"
  cpus                  = "${var.cpus}"
  disk_block_size       = "1"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = "true"
  enable_secure_boot    = "true"
  secure_boot_template  = "MicrosoftUEFICertificateAuthority"
  generation            = 2
  guest_additions_mode  = "disable"
  // http_directory        = "./http"
  iso_checksum          = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url               = "${var.iso_url}"
  // https://www.packer.io/plugins/builders/hyperv/iso#cd_files
  // https://wiki.debian.org/CDDVD
  // https://github.com/brantleyp1/packer-image-builder/blob/dec07815501f30f2f96a653805048af5193ed333/vsphere.pkr.hcl
  // https://github.com/brantleyp1/packer-image-builder/blob/dec07815501f30f2f96a653805048af5193ed333/rocky8.pkrvars.hcl
  cd_files              = "${var.cd_files}"
  cd_label              = "${var.cd_label}"
  memory                = "${var.memory}"
  output_directory      = "${var.output_directory}"
  skip_export           = "true"
  shutdown_command      = "sudo -S shutdown -P now"
  shutdown_timeout      = "60m"
  // ssh_password          = "vagrant"
  // ssh_timeout           = "4h"
  // ssh_username          = "vagrant"
  switch_name           = "${var.switch_name}"
  temp_path             = "."
  vlan_id               = "${var.vlan_id}"
  vm_name               = "${var.vm_name}"
}

build {
  sources = ["source.hyperv-iso.vm"]

  // provisioner "shell" {
  //   execute_command = "echo ${var.ssh_password} | sudo -S -E bash {{ .Path }}"
  //   script          = "./http/provision.sh"
  // }

  // post-processor "vagrant" {
  //   keep_input_artifact  = true
  //   output               = "${var.output_vagrant}"
  //   vagrantfile_template = "${var.vagrantfile_template}"
  // }
}
