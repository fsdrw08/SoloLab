output "resource_group_id" {
  value = alicloud_resource_manager_resource_group.devops.id
}


output "vswitch_zone_id" {
  value = data.alicloud_zones.vswitch.zones.0.id
}

output "vpc_id" {
  value = alicloud_vpc.devops.id
}

output "security_group_id" {
  value = alicloud_security_group.devops.id
}
