data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  name_regex        = var.vpc_name_regex
}

data "alicloud_vswitches" "vsw" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
  name_regex        = var.vswitch_name_regex
}

resource "alicloud_ecs_disk" "d_data" {
  count                = length(var.data_disks_name)
  resource_group_id    = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  zone_id              = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  disk_name            = element(var.data_disks_name, count.index)
  category             = var.data_disk_category
  performance_level    = var.data_disk_performance_level
  size                 = var.data_disk_size
  payment_type         = var.data_disk_payment_type
  description          = "This resource is managed by terraform"
  delete_with_instance = false
}

# resource "alicloud_ecs_disk" "d_agent_data" {
#   resource_group_id    = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
#   zone_id              = data.alicloud_vswitches.vsw.vswitches.0.zone_id
#   disk_name            = var.agent_data_disk_name
#   category             = var.data_disk_category
#   performance_level    = var.data_disk_performance_level
#   size                 = var.data_disk_size
#   payment_type         = var.data_disk_payment_type
#   description          = "This resource is managed by terraform"
#   delete_with_instance = false
# }

# resource "alicloud_ecs_snapshot" "gitlab_d_snpsh" {
#   resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
#   category          = "standard"
#   description       = "This resource is managed by terraform"
#   disk_id           = alicloud_ecs_disk.gitlab_data.id
#   retention_days    = "20"
#   snapshot_name     = "DevOps_Disk-gitlab_data-snapshot"
# }
