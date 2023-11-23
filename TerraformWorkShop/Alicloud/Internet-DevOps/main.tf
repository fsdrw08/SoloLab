locals {
  eip_count = 1
}

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

data "alicloud_vpc_ipv4_gateways" "ipv4gw" {
  name_regex = var.ipv4_gateway_name_regex
}

data "alicloud_eip_addresses" "ngw_eip" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  isp               = "BGP"
}

# nat gateway vswitch
resource "alicloud_vswitch" "ngw_vsw" {
  vpc_id       = data.alicloud_vpcs.vpc.vpcs.0.id
  zone_id      = data.alicloud_zones.az.zones[0].id
  vswitch_name = var.nat_gateway_vswitch_name
  cidr_block   = var.nat_gateway_vswitch_cidr
  description  = "This resource is managed by terraform"
  tags = {
    "Name" = var.nat_gateway_vswitch_name
  }
}

resource "alicloud_route_table" "ngw_vsw_vtb" {
  vpc_id           = data.alicloud_vpcs.vpc.vpcs.0.id
  route_table_name = var.nat_gateway_vswitch_route_table_name
  description      = "This resource is managed by terraform"
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "ngw_to_ipv4gw" {
  route_table_id        = alicloud_route_table.ngw_vsw_vtb.id
  nexthop_id            = data.alicloud_vpc_ipv4_gateways.ipv4gw.gateways.0.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
}

# nat gateway
# https://github.com/alibaba/terraform-provider/blob/fbeb53e990dfde330c7c2e9fce5630ac56138d32/examples/vpc-snat/main.tf#L50
resource "alicloud_nat_gateway" "ngw" {
  vpc_id           = data.alicloud_vpcs.vpc.vpcs.0.id
  vswitch_id       = alicloud_vswitch.ngw_vsw.id
  nat_gateway_name = var.nat_gateway_name
  description      = "This resource is managed by terraform"
  # fixed params:
  internet_charge_type = "PayByLcu"
  nat_type             = "Enhanced"
  network_type         = "internet"
  # https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nat_gateway#eip_bind_mode
  # https://help.aliyun.com/document_detail/120219.html
  eip_bind_mode = "NAT"
}

# eip
# resource "alicloud_eip_address" "ngw_eip" {
#   count                = local.eip_count
#   resource_group_id    = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
#   address_name         = "${var.nat_gateway_eip_address_name}-EIP-${count.index + 1}"
#   bandwidth            = var.nat_gateway_eip_bandwidth
#   internet_charge_type = var.nat_gateway_eip_internet_charge_type
#   description          = "This resource is managed by terraform"
#   # fixed params:
#   isp          = "BGP"
#   netmode      = "public"
#   payment_type = "PayAsYouGo"
# }

resource "alicloud_eip_association" "ngw_eip_assn" {
  count         = local.eip_count
  allocation_id = data.alicloud_eip_addresses.ngw_eip.addresses[count.index].allocation_id
  instance_id   = alicloud_nat_gateway.ngw.id
}

# nat entry
resource "alicloud_snat_entry" "snat" {
  depends_on        = [alicloud_eip_association.ngw_eip_assn]
  snat_table_id     = alicloud_nat_gateway.ngw.snat_table_ids
  source_vswitch_id = alicloud_vswitch.ngw_vsw.id
  snat_ip           = data.alicloud_eip_addresses.ngw_eip.addresses[0].ip_address
}


# vpn gateway
# https://github.com/jeremypedersen/terraformExamples/blob/f8e33f1266fbd64cc834001f8710bfd36e4fa7aa/abc/vpn-nat-demo/main.tf#L97
# resource "alicloud_vpn_gateway" "vpn" {
#   name                 = "DevOps-Root-vpn"
#   vpc_id               = data.alicloud_vpcs.vpc.vpcs.0.id
#   auto_propagate       = true
#   instance_charge_type = "PostPaid"
#   bandwidth            = "10"
#   enable_ssl           = true
#   ssl_connections      = "5"
#   vswitch_id           = data.alicloud_vswitches.vsw.vswitches.0.id
#   description          = "vpn for team access"
# }

# resource "alicloud_ssl_vpn_server" "vss" {
#   name           = "DevOps_VPN_SSL_Server"
#   vpn_gateway_id = alicloud_vpn_gateway.vpn.id
#   client_ip_pool = "10.0.0.0/27"
#   local_subnet   = "${data.alicloud_vswitches.vsw.vswitches.0.cidr_block},100.100.2.136/30"
#   protocol       = "TCP"
#   cipher         = "AES-128-CBC"
#   port           = 1194
#   compress       = "false"
# }

# resource "alicloud_ssl_vpn_client_cert" "vsc" {
#   name              = "vpn_cert_test"
#   ssl_vpn_server_id = alicloud_ssl_vpn_server.vss.id
# }
