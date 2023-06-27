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

resource "alicloud_eip_address" "eip" {
  count                = local.eip_count
  address_name         = "DevOps_EIP-${count.index + 1}"
  bandwidth            = 5
  description          = "This resource is managed by terraform"
  internet_charge_type = "PayByTraffic"
  isp                  = "BGP"
  netmode              = "public"
  payment_type         = "PayAsYouGo"
  resource_group_id    = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}


# https://github.com/alibaba/terraform-provider/blob/fbeb53e990dfde330c7c2e9fce5630ac56138d32/examples/vpc-snat/main.tf#L50
resource "alicloud_nat_gateway" "ngw" {
  internet_charge_type = "PayByLcu"
  description          = "This resource is managed by terraform"
  nat_gateway_name     = "DevOps_NAT_Gateway"
  nat_type             = "Enhanced"
  network_type         = "internet"
  specification        = "Small"
  vpc_id               = data.alicloud_vpcs.vpc.vpcs.0.id
  vswitch_id           = data.alicloud_vswitches.vsw.vswitches.0.id
}

resource "alicloud_eip_association" "eip_assn" {
  count         = local.eip_count
  allocation_id = alicloud_eip_address.eip.*.id[count.index]
  instance_id   = alicloud_nat_gateway.ngw.id
}

resource "alicloud_snat_entry" "snat" {
  depends_on        = [alicloud_eip_association.eip_assn]
  snat_table_id     = alicloud_nat_gateway.ngw.snat_table_ids
  source_vswitch_id = data.alicloud_vswitches.vsw.vswitches.0.id
  snat_ip           = alicloud_eip_address.eip[0].ip_address
}

resource "alicloud_alidns_record" "alidnscheck" {
  domain_name = var.domain_name
  rr          = "alidnscheck"
  remark      = "For Proving DNS Ownership"
  status      = "ENABLE"
  ttl         = "86400"
  type        = "TXT"
  value       = "c76842bdc6ac4e59bffacb1ad8df8f2d"
}

resource "alicloud_alidns_record" "r-proxy" {
  domain_name = var.domain_name
  rr          = "r-proxy"
  remark      = "reverse proxy traefik mgmt web"
  status      = "ENABLE"
  ttl         = "600"
  type        = "A"
  value       = alicloud_eip_address.eip[0].ip_address
}
