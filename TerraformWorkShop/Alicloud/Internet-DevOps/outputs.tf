output "eip_addresses" {
  value = data.alicloud_eip_addresses.ngw_eip.addresses.*.ip_address
}
