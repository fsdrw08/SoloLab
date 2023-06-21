output "eip_addresses" {
  value = alicloud_eip_address.devops.*.ip_address
}

output "nat_gateway_forward_table_ids" {
  value = alicloud_nat_gateway.devops.forward_table_ids
}
