output "resource_group_id" {
  value = alicloud_resource_manager_resource_group.devops.id
}


output "vswitch_zone_id" {
  value = data.alicloud_zones.vswitch.zones.0.id
}

output "vpc_id" {
  value = alicloud_vpc.devops.id
}

output "vswitch_id" {
  value = alicloud_vswitch.devops.id
}

output "security_group_id" {
  value = alicloud_security_group.devops.id
}

# output "eip_address" {
#   value = alicloud_eip_address.devops.ip_address
# }

# output "forward_table_ids" {
#   value = alicloud_nat_gateway.devops.forward_table_ids
# }
