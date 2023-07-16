data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = "^${var.resource_group_name}"
}

data "alicloud_vpcs" "vpc" {
  name_regex        = "^${var.vpc_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = "^${var.vswitch_name}"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

resource "alicloud_ecs_disk" "gitlab_data" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  category          = "cloud_essd"
  performance_level = "PL0"
  disk_name         = "DevOps_Disk-gitlab_data"
  description       = "This resource is managed by terraform"
  size              = "200"
  zone_id           = data.alicloud_vswitches.vsw.vswitches.0.zone_id
}

resource "alicloud_ecs_snapshot" "s-gitlab_data" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  category          = "standard"
  description       = "This resource is managed by terraform"
  disk_id           = alicloud_ecs_disk.gitlab_data.id
  retention_days    = "20"
  snapshot_name     = "DevOps_Disk-gitlab_data-snapshot"
}
