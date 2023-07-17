data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_zones" "az" {
  available_resource_creation = "Disk"
  instance_charge_type        = "PostPaid"
  network_type                = "Vpc"
}

resource "alicloud_ecs_disk" "gitlab_d" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  disk_name         = var.data_disk_name
  category          = var.data_disk_category
  performance_level = var.data_disk_performance_level
  size              = var.data_disk_size
  zone_id           = data.alicloud_zones.az.zones.0.id
  description       = "This resource is managed by terraform"
}

# resource "alicloud_ecs_snapshot" "gitlab_d_snpsh" {
#   resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
#   category          = "standard"
#   description       = "This resource is managed by terraform"
#   disk_id           = alicloud_ecs_disk.gitlab_data.id
#   retention_days    = "20"
#   snapshot_name     = "DevOps_Disk-gitlab_data-snapshot"
# }
