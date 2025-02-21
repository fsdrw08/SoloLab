resource "hyperv_vhd" "data" {
  path       = var.vhd.path
  vhd_type   = var.vhd.type
  size       = var.vhd.size
  block_size = var.vhd.block_size
}

# resource "hyperv_vhd" "data" {
#   count = var.vhd_count

#   path = join("\\", [
#     var.vhd.dir,
#     var.vhd_count <= 1 ? "${var.vhd.basename}" :
#     format("%s%s.%s",
#       split(".", var.vhd.basename)[0],
#       "_${count.index + 1}",
#       split(".", var.vhd.basename)[1]
#     )
#     # join(".", split(".", var.vhd.basename)[0],
#     #   "${count.index + 1}",
#     # split(".", var.vhd.basename)[1])
#   ])
#   vhd_type   = var.vhd.type
#   size       = var.vhd.size
#   block_size = var.vhd.block_size
# }
