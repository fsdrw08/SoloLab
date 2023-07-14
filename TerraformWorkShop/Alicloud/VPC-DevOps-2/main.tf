# cn_gz
data "alicloud_zones" "vsw" {
  available_resource_creation = "VSwitch"
}

data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = "^${var.resource_group_name}"
}

# vpc related
resource "alicloud_vpc" "vpc" {
  vpc_name          = "DevOps_CNGZ"
  cidr_block        = "172.32.0.0/12"
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps_CNGZ"
  }
}

# vswitch
resource "alicloud_vswitch" "vsw" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.32.1.0/24"
  zone_id      = data.alicloud_zones.vsw.zones[0].id
  vswitch_name = "DevOps_CNGZ"
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps_CNGZ"
  }
}

# security group
resource "alicloud_security_group" "sg" {
  name                = "DevOps_CNGZ"
  resource_group_id   = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  security_group_type = "normal"
  vpc_id              = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "sgr_allow_all_in" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 10
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}
