resource "hyperv_vhd" "boot_disk" {
  path   = var.boot_disk.path
  source = var.boot_disk_source
}
