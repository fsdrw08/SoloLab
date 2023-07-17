output "eip_addresses" {
  value = alicloud_eip_address.ngw_eip.*.ip_address
}
