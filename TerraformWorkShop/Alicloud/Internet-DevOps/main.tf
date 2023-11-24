locals {
  eip_count = 1
}

data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

## eip
# https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address
resource "alicloud_eip_address" "eip" {
  for_each             = var.eip
  resource_group_id    = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  address_name         = each.value.address_name
  payment_type         = each.value.payment_type
  internet_charge_type = each.value.internet_charge_type
  auto_pay             = each.value.auto_pay
  isp                  = each.value.isp
  bandwidth            = each.value.bandwidth
  description          = each.value.description
}
