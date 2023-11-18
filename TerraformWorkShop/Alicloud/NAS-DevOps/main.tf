data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = var.vswitch_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_file_system
resource "alicloud_nas_file_system" "nas_fs" {
  vpc_id     = data.alicloud_vpcs.vpc.vpcs.0.id
  vswitch_id = data.alicloud_vswitches.vsw.vswitches.0.id
  zone_id    = data.alicloud_vswitches.vsw.vswitches[0].zone_id

  file_system_type = var.nas_fs_type
  storage_type     = var.nas_fs_storage_type
  protocol_type    = var.nas_fs_protocol_type
  description      = var.nas_fs_desc
}

# https://github.com/kwoodson/terraform-openshift-alibaba/blob/5eb55f2baa7d4894f7e9b99c4664e33807715df5/nas/nas.tf#L1
resource "alicloud_nas_access_group" "nas_ag" {
  access_group_name = var.nas_ag_name
  access_group_type = "Vpc"
}

resource "alicloud_nas_access_rule" "nas_ar" {
  access_group_name = alicloud_nas_access_group.nas_ag.access_group_name
  source_cidr_ip    = data.alicloud_vpcs.vpc.vpcs.0.cidr_block
  rw_access_type    = var.nas_ar_rw_access_type
  user_access_type  = "no_squash"
  priority          = 1
}

resource "alicloud_nas_mount_target" "nas_mt" {
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id
  file_system_id    = alicloud_nas_file_system.nas_fs.id
  access_group_name = alicloud_nas_access_group.nas_ag.access_group_name
}
