locals {
  eip_count = 1
}

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

# https://github.com/jeremypedersen/terraformExamples/blob/f8e33f1266fbd64cc834001f8710bfd36e4fa7aa/abc/vpn-nat-demo/main.tf#L97
resource "alicloud_vpn_gateway" "vpn" {
  name                 = "DevOps_CNGZ-VPN_Gateway"
  vpc_id               = data.alicloud_vpcs.vpc.vpcs.0.id
  auto_propagate       = true
  instance_charge_type = "PostPaid"
  bandwidth            = "10"
  enable_ssl           = true
  ssl_connections      = "5"
  vswitch_id           = data.alicloud_vswitches.vsw.vswitches.0.id
  description          = "vpn for team access"
}

resource "alicloud_ssl_vpn_server" "vss" {
  name           = "DevOps_CNGZ-VPN_SSL_Server"
  vpn_gateway_id = alicloud_vpn_gateway.vpn.id
  client_ip_pool = "10.0.0.0/27"
  local_subnet   = "${data.alicloud_vswitches.vsw.vswitches.0.cidr_block},100.100.2.136/30"
  protocol       = "TCP"
  cipher         = "AES-128-CBC"
  port           = 1194
  compress       = "false"
}

resource "alicloud_ssl_vpn_client_cert" "vsc" {
  name              = "DevOps_CNGZ-vpn_cert_test"
  ssl_vpn_server_id = alicloud_ssl_vpn_server.vss.id
}
