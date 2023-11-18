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

data "alicloud_nat_gateways" "ngw" {
  name_regex        = var.nat_gateway_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
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
resource "alicloud_slb_load_balancer" "slb_inst" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id

  load_balancer_name   = var.slb_load_balancer_name
  load_balancer_spec   = var.slb_load_balancer_spec
  address_type         = "intranet"
  payment_type         = "PayAsYouGo"
  instance_charge_type = "PayBySpec"
}

resource "alicloud_slb_listener" "slb_listener" {
  load_balancer_id      = alicloud_slb_load_balancer.slb_inst.id
  frontend_port         = 443
  backend_port          = 8080
  listener_forward      = "on"
  protocol              = "https"
  bandwidth             = -1
  server_certificate_id = alicloud_slb_server_certificate.default.id
}

# nat forward entry to forward request from nat to slb
resource "alicloud_forward_entry" "fwd_https" {
  forward_entry_name = var.slb_load_balancer_name
  forward_table_id   = data.alicloud_nat_gateways.ngw.gateways[0].forward_table_ids[0]
  external_ip        = data.alicloud_nat_gateways.ngw.gateways.0.ip_lists.0
  external_port      = "443"
  ip_protocol        = "tcp"
  internal_ip        = alicloud_slb_load_balancer.slb_inst.address
  internal_port      = "443"
  port_break         = true
}
