resource "hyperv_vhd" "data" {
  for_each = {
    for vhd in var.vhds : basename(vhd.path) => vhd
  }
  path       = each.value.path
  vhd_type   = each.value.type
  size       = each.value.size
  block_size = each.value.block_size
  lifecycle {
    prevent_destroy = true
  }
}
