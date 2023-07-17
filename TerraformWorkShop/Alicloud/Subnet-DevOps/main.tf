data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_zones" "az" {
  available_instance_type     = "ecs.t6-c1m4.large"
  available_resource_creation = "Instance"
  instance_charge_type        = "PostPaid"
  network_type                = "Vpc"
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_nat_gateways" "ngw" {
  name_regex = var.nat_gateway_name_regex
  vpc_id     = data.alicloud_vpcs.vpc.vpcs.0.id
}


# subnet vswitch
resource "alicloud_vswitch" "sub_vsw" {
  vpc_id       = data.alicloud_vpcs.vpc.vpcs.0.id
  zone_id      = data.alicloud_zones.az.zones[0].id
  vswitch_name = var.subnet_vswitch_name
  cidr_block   = var.subnet_vswitch_cidr
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = var.subnet_vswitch_name
  }
}

resource "alicloud_route_table" "sub_vsw_vtb" {
  vpc_id           = data.alicloud_vpcs.vpc.vpcs.0.id
  route_table_name = var.subnet_vswitch_route_table_name
  description      = "This resource is managed by terraform"
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "sub_vsw_vtb_attm" {
  vswitch_id     = alicloud_vswitch.sub_vsw.id
  route_table_id = alicloud_route_table.sub_vsw_vtb.id
}

resource "alicloud_route_entry" "sub_to_ngw" {
  route_table_id        = alicloud_route_table.sub_vsw_vtb.id
  nexthop_id            = data.alicloud_nat_gateways.ngw.gateways.0.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
}

# resource "alicloud_route_entry" "local" {
#   route_table_id        = alicloud_route_table.sub_vsw_vtb.id
#   nexthop_id            = data.alicloud_vpc_ipv4_gateways.ipv4gw.gateways.0.id
#   destination_cidrblock = var.subnet_vswitch_cidr
#   nexthop_type          = "local"
# }

# security group
resource "alicloud_security_group" "sub_sg" {
  vpc_id              = data.alicloud_vpcs.vpc.vpcs.0.id
  resource_group_id   = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  name                = var.subnet_security_group_name
  inner_access_policy = "Accept"
}

resource "alicloud_security_group_rule" "sub_sgr_allow_all_in" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 10
  security_group_id = alicloud_security_group.sub_sg.id
  cidr_ip           = "0.0.0.0/0"
}


# subnet snat
resource "alicloud_snat_entry" "sub_snat" {
  depends_on        = [alicloud_vswitch.sub_vsw]
  snat_table_id     = data.alicloud_nat_gateways.ngw.gateways.0.snat_table_ids.0
  snat_ip           = data.alicloud_nat_gateways.ngw.gateways.0.ip_lists.0
  source_vswitch_id = alicloud_vswitch.sub_vsw.id
}
