resource "hyperv_vhd" "data" {
  path       = var.vhd.path
  vhd_type   = var.vhd.type
  size       = var.vhd.size
  block_size = var.vhd.block_size
}
