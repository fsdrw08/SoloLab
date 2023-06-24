output "eip_addresses" {
  value = alicloud_eip_address.eip.*.ip_address
}
