output "path" {
  value = hyperv_vhd.data.path
  # value = tomap({
  #   for index, value in hyperv_vhd.data :
  #   index => value.path
  # })
}
