# vswitch
resource "alicloud_vswitch" "vsw" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_cidr
  zone_id      = data.alicloud_zones.az.zones[0].id
  vswitch_name = var.vswitch_name
  description  = var.vswitch_description
  tags = {
    "Name" = var.vswitch_name
  }
}

# security group related
resource "alicloud_security_group" "sg" {
  name                = var.security_group_name
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
  priority          = 100
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}
