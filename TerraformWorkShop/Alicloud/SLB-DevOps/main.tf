data "alicloud_resource_manager_resource_groups" "rg" {
  name_regex = var.resource_group_name_regex
}

data "alicloud_vpcs" "vpc" {
  name_regex        = var.vpc_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_vswitches" "vsw" {
  for_each          = var.slb_web_internal
  name_regex        = each.value.vswitch_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_nat_gateways" "ngw" {
  # https://discuss.hashicorp.com/t/conditionally-create-resources-when-a-for-each-loop-is-involved/20841/2
  for_each = {
    for k, v in var.slb_web_internal :
    k => v if v.nat_gateway_name_regex != null
  }
  name_regex        = each.value.nat_gateway_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_eip_addresses" "eip" {
  for_each = {
    for k, v in var.slb_web_internal :
    k => v if v.eip_name_regex != null
  }
  # for_each          = var.slb_web_internal
  name_regex        = each.value.eip_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

# self sign cert as slb listener default cert
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# self sign cert
resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 43800

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "alicloud_slb_server_certificate" "default" {
  resource_group_id  = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  name               = "default"
  server_certificate = tls_self_signed_cert.default.cert_pem
  private_key        = tls_self_signed_cert.default.private_key_pem
}

# slb instance
# ref: https://github.com/alibabacloud-automation/terraform-alicloud-slb-rule/blob/74bbe668feb57f61661cf38e6ef8f5bde8ac03df/main.tf
resource "alicloud_slb_load_balancer" "lb" {
  for_each          = var.slb_web_internal
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vswitch_id        = data.alicloud_vswitches.vsw[each.key].vswitches.0.id

  load_balancer_name   = each.value.name
  address_type         = "intranet"
  payment_type         = "PayAsYouGo"
  instance_charge_type = each.value.instance_charge_type
  load_balancer_spec   = each.value.load_balancer_spec
}

resource "alicloud_slb_listener" "lb_listener_https" {
  for_each                  = var.slb_web_internal
  load_balancer_id          = alicloud_slb_load_balancer.lb[each.key].id
  protocol                  = "https"
  description               = "https_443"
  frontend_port             = 443
  backend_port              = each.value.listener_backend_port
  listener_forward          = "on"
  bandwidth                 = -1
  health_check              = "off"
  proxy_protocol_v2_enabled = true
  server_certificate_id     = alicloud_slb_server_certificate.default.id
  # https://stackoverflow.com/questions/42267602/why-does-jenkins-say-my-reverse-proxy-setup-is-broken
  x_forwarded_for {
    retrive_slb_proto = true
  }
}

resource "alicloud_slb_listener" "lb_listener_http" {
  for_each         = var.slb_web_internal
  load_balancer_id = alicloud_slb_load_balancer.lb[each.key].id
  protocol         = "http"
  description      = "http_80"
  frontend_port    = 80
  listener_forward = "on"
  forward_port     = alicloud_slb_listener.lb_listener_https[each.key].frontend_port
}

# nat forward entry to forward request from nat to slb
resource "alicloud_forward_entry" "fwd_https" {
  for_each = {
    for k, v in var.slb_web_internal :
    k => v if v.nat_gateway_name_regex != null && v.eip_name_regex != null
  }
  forward_entry_name = "${each.value.name}_https"
  forward_table_id   = data.alicloud_nat_gateways.ngw[each.key].gateways[0].forward_table_ids[0]
  external_ip        = data.alicloud_eip_addresses.eip[each.key].addresses[0].ip_address
  external_port      = "443"
  ip_protocol        = "tcp"
  internal_ip        = alicloud_slb_load_balancer.lb[each.key].address
  internal_port      = "443"
  port_break         = true
}

resource "alicloud_forward_entry" "fwd_http" {
  for_each = {
    for k, v in var.slb_web_internal :
    k => v if v.nat_gateway_name_regex != null && v.eip_name_regex != null
  }
  forward_entry_name = "${each.value.name}_http"
  forward_table_id   = data.alicloud_nat_gateways.ngw[each.key].gateways[0].forward_table_ids[0]
  external_ip        = data.alicloud_eip_addresses.eip[each.key].addresses[0].ip_address
  external_port      = "80"
  ip_protocol        = "tcp"
  internal_ip        = alicloud_slb_load_balancer.lb[each.key].address
  internal_port      = "80"
  port_break         = true
}
