# cn_gz
# vpc related
resource "alicloud_vpc" "vpc" {
  vpc_name          = "DevOps_CNZG"
  cidr_block        = "172.32.0.0/12"
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

# vswitch
resource "alicloud_vswitch" "vsw_cngz" {
  vpc_id       = alicloud_vpc.vpc_cngz.id
  cidr_block   = "172.32.1.0/24"
  zone_id      = data.alicloud_zones.vsw_cngz.zones[0].id
  vswitch_name = "DevOps_CNGZ"
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}
