data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  name_regex        = var.vswitch_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

# ref: https://github.com/alibabacloud-automation/terraform-alicloud-slb-rule/blob/74bbe668feb57f61661cf38e6ef8f5bde8ac03df/main.tf
resource "alicloud_slb_load_balancer" "slb_inst" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id

  load_balancer_name   = var.slb_load_balancer_name
  load_balancer_spec   = var.slb_load_balancer_spec
  address_type         = "intranet"
  payment_type         = "PayAsYouGo"
  instance_charge_type = "PayBySpec"
}

# resource "alicloud_slb_listener" "slb_listener" {
#   load_balancer_id = alicloud_slb_load_balancer.slb_inst.id
#   frontend_port    = 443
#   protocol         = "https"
# }
