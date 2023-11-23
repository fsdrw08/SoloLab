data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_zones" "az" {
  available_instance_type     = var.zone_available_instance_type
  available_resource_creation = "VSwitch"
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
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  vpc_id       = data.alicloud_vpcs.vpc.vpcs.0.id
  zone_id      = each.value.zone_id
  vswitch_name = each.value.name
  cidr_block   = each.value.cidr_block
  description  = "This resource is managed by terraform"
}

# resource "alicloud_vswitch" "sub_vsw" {
#   vpc_id       = data.alicloud_vpcs.vpc.vpcs.0.id
#   zone_id      = data.alicloud_zones.az.zones[0].id
#   vswitch_name = var.subnet_vswitch_name
#   cidr_block   = var.subnet_vswitch_cidr
#   description  = "This resource is managed by terraform"
#   tags = {
#     "Name" = var.subnet_vswitch_name
#   }
# }

resource "alicloud_route_table" "sub_vsw_vtb" {
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  vpc_id           = data.alicloud_vpcs.vpc.vpcs.0.id
  route_table_name = each.value.route_table_name
  description      = "This resource is managed by terraform"
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "sub_vsw_vtb_attm" {
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  vswitch_id     = alicloud_vswitch.sub_vsw[each.key].id
  route_table_id = alicloud_route_table.sub_vsw_vtb[each.key].id
}

resource "alicloud_route_entry" "sub_to_ngw" {
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  route_table_id        = alicloud_route_table.sub_vsw_vtb[each.key].id
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
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  vpc_id              = data.alicloud_vpcs.vpc.vpcs.0.id
  resource_group_id   = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  name                = each.value.security_group_name
  inner_access_policy = "Accept"
}

resource "alicloud_security_group_rule" "sub_sgr_allow_all_in" {
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 10
  security_group_id = alicloud_security_group.sub_sg[each.key].id
  cidr_ip           = "0.0.0.0/0"
}


# subnet snat
resource "alicloud_snat_entry" "sub_snat" {
  for_each = {
    for vsw in var.subnet_vswitches : vsw.name => vsw
  }
  depends_on        = [alicloud_vswitch.sub_vsw]
  snat_table_id     = data.alicloud_nat_gateways.ngw.gateways.0.snat_table_ids.0
  snat_ip           = data.alicloud_nat_gateways.ngw.gateways.0.ip_lists.0
  source_vswitch_id = alicloud_vswitch.sub_vsw[each.key].id
}
