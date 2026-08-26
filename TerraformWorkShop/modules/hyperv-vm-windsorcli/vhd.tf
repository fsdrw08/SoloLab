# resource "hyperv_vhd" "boot_disk" {
#   path                 = var.boot_disk.path
#   block_size           = var.boot_disk.block_size
#   logical_sector_size  = var.boot_disk.logical_sector_size
#   parent_path          = var.boot_disk.parent_path
#   physical_sector_size = var.boot_disk.physical_sector_size
#   size                 = var.boot_disk.size
#   source               = var.boot_disk.source
#   source_disk          = var.boot_disk.source_disk
#   source_vm            = var.boot_disk.source_vm
#   vhd_type             = var.boot_disk.vhd_type
#   timeouts             = var.boot_disk.timeouts
# }

# resource "hyperv_vhd" "additional_disks" {
#   path                 = var.additional_disks.path
#   block_size           = var.additional_disks.block_size
#   logical_sector_size  = var.additional_disks.logical_sector_size
#   parent_path          = var.additional_disks.parent_path
#   physical_sector_size = var.additional_disks.physical_sector_size
#   size                 = var.additional_disks.size
#   source               = var.additional_disks.source
#   source_disk          = var.additional_disks.source_disk
#   source_vm            = var.additional_disks.source_vm
#   vhd_type             = var.additional_disks.vhd_type
#   timeouts             = var.additional_disks.timeouts
# }
