output "vhds" {
  # value = hyperv_vhd.data.path
  value = [
    for vhd in var.vhds : {
      name = basename(vhd.path)
      path = hyperv_vhd.data[basename(vhd.path)].path
    }
  ]
}
