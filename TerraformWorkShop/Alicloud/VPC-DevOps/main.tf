data "alicloud_zones" "vsw" {
  provider                    = alicloud.ap_sg
  available_resource_creation = "VSwitch"
}

# resource group
resource "alicloud_resource_manager_resource_group" "rg" {
  provider            = alicloud.ap_sg
  resource_group_name = "devops"
  display_name        = "DevOps"
}

# vpc related
resource "alicloud_vpc" "vpc" {
  provider          = alicloud.ap_sg
  vpc_name          = "DevOps_VPC"
  cidr_block        = "172.16.0.0/12"
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  description       = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

# vswitch
resource "alicloud_vswitch" "vsw" {
  provider     = alicloud.ap_sg
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.1.0/24"
  zone_id      = data.alicloud_zones.vsw.zones[0].id
  vswitch_name = "DevOps_VSwitch"
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = "DevOps"
  }
}

# security group related
resource "alicloud_security_group" "sg" {
  provider            = alicloud.ap_sg
  name                = "DevOps_SG"
  resource_group_id   = alicloud_resource_manager_resource_group.rg.id
  security_group_type = "normal"
  vpc_id              = alicloud_vpc.vpc.id
}


resource "alicloud_security_group_rule" "allow_all_tcp_in" {
  provider          = alicloud.ap_sg
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 10
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

// Using this data source can open Private Zone service automatically.
# https://github.com/openshift/installer/blob/de6e40773cee904bfea1d2bafae4149d58277d83/data/data/alibabacloud/cluster/dns/privatezone.tf#L5
data "alicloud_pvtz_service" "pvtz_enable" {
  provider = alicloud.ap_sg
  enable   = "On"
}

resource "alicloud_pvtz_zone" "pvtz" {
  provider          = alicloud.ap_sg
  resource_group_id = alicloud_resource_manager_resource_group.rg.id
  zone_name         = "devops.p2w3"
  sync_status       = "ON"
}

resource "alicloud_pvtz_zone_attachment" "pvtz_attm" {
  provider = alicloud.ap_sg
  zone_id  = alicloud_pvtz_zone.pvtz.id
  vpc_ids  = [alicloud_vpc.vpc.id]
}
