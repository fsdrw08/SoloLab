locals {
  all_disk_drives = var.additional_disk_drives == null ? [var.boot_disk_drive] : concat([var.boot_disk_drive], var.additional_disk_drives)
}

resource "hyperv_image_file" "boot_disk" {
  # Required
  path     = var.boot_disk.path
  vhd_type = var.boot_disk.vhd_type
  # Optional
  block_size_bytes = var.boot_disk.block_size_bytes
  parent_path      = var.boot_disk.parent_path
  size_bytes       = var.boot_disk.size_bytes
}

# https://github.com/terraform-google-modules/terraform-google-vm/blob/v8.0.1/modules/instance_template/main.tf
resource "hyperv_vm" "vm" {
  depends_on = [hyperv_image_file.boot_disk]
  # Required
  cpu = {
    count = var.vm.cpu_count
  }
  generation = var.vm.generation
  memory = {
    startup_bytes = var.vm.memory.startup_bytes
    dynamic       = var.vm.memory.dynamic
    max_bytes     = var.vm.memory.max_bytes
    min_bytes     = var.vm.memory.min_bytes
  }
  name = var.vm.name
  # Optional
  boot_order = [
    for boot_order in var.vm.boot_order : {
      type                = boot_order.type
      controller_location = boot_order.controller_location
      controller_number   = boot_order.controller_number
      controller_type     = boot_order.controller_type
      name                = boot_order.name
    }
  ]
  dvd_drive = [
    for dvd_drive in var.vm.dvd_drive : {
      controller_location = dvd_drive.controller_location
      controller_number   = dvd_drive.controller_number
      controller_type     = dvd_drive.controller_type
      iso_path            = dvd_drive.iso_path
    }
  ]
  hard_disk_drive = [
    for hard_disk_drive in local.all_disk_drives : {
      controller_location = hard_disk_drive.controller_location
      controller_number   = hard_disk_drive.controller_number
      controller_type     = hard_disk_drive.controller_type
      path                = hard_disk_drive.path
    }
  ]
  network_adapter = [
    for network_adapter in var.vm.network_adapter : {
      name        = network_adapter.name
      switch_name = network_adapter.switch_name
      mac_address = network_adapter.mac_address
      vlan_id     = network_adapter.vlan_id
    }
  ]
  notes                = var.vm.notes
  secure_boot          = var.vm.secure_boot
  secure_boot_template = var.vm.secure_boot_template
  state = {
    desired       = var.vm.state.desired
    shutdown_mode = var.vm.state.shutdown_mode
    turn_off      = var.vm.state.turn_off
    graceful      = var.vm.state.graceful
  }
}
