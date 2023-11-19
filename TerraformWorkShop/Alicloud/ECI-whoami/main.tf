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

data "alicloud_security_groups" "sg" {
  name_regex        = var.security_group_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_slb_load_balancers" "slb" {
  name_regex        = var.load_balancer_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

data "alicloud_slb_listeners" "slb_listener" {
  load_balancer_id = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port    = 443
}

data "alicloud_slb_server_certificates" "slb_cert" {
  name_regex        = var.slb_cert_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
}

data "alicloud_nat_gateways" "ngw" {
  name_regex        = var.nat_gateway_name_regex
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  vpc_id            = data.alicloud_vpcs.vpc.vpcs.0.id
}

resource "alicloud_eci_container_group" "whoami" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  zone_id           = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id
  security_group_id = data.alicloud_security_groups.sg.groups.0.id

  container_group_name = var.eci_group_name
  instance_type        = var.ecs_instance_type
  restart_policy       = var.eci_restart_policy

  containers {
    image             = var.eci_image_uri
    name              = var.eci_group_name
    image_pull_policy = "IfNotPresent"

    ports {
      port     = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
      protocol = "TCP"
    }
    environment_vars {
      key   = "WHOAMI_PORT_NUMBER"
      value = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
    }
  }
}

# https://github.com/hatlonely/notebook/blob/f4dd810dc6032d4b04e76455835cbcd1840fec7a/terraform/code/alicloud/best-practise/2-eci-web-service/slb.tf#L17
resource "alicloud_slb_server_group" "slb_svr_group" {
  name             = var.eci_group_name
  load_balancer_id = data.alicloud_slb_load_balancers.slb.balancers.0.id
}

resource "alicloud_slb_server_group_server_attachment" "slb_attach" {
  server_group_id = alicloud_slb_server_group.slb_svr_group.id
  server_id       = alicloud_eci_container_group.whoami.id
  port            = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
}

resource "alicloud_slb_rule" "slb_rule" {
  depends_on       = [alicloud_slb_domain_extension.slb_dext]
  load_balancer_id = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port    = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.frontend_port
  name             = var.eci_group_name
  domain           = "${var.subdomain}.${var.root_domain}"
  server_group_id  = alicloud_slb_server_group.slb_svr_group.id
}

resource "alicloud_slb_domain_extension" "slb_dext" {
  load_balancer_id      = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port         = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.frontend_port
  domain                = "${var.subdomain}.${var.root_domain}"
  server_certificate_id = data.alicloud_slb_server_certificates.slb_cert.certificates.0.id
}

resource "alicloud_alidns_record" "record" {
  domain_name = var.root_domain
  rr          = var.subdomain
  type        = "A"
  value       = data.alicloud_nat_gateways.ngw.gateways.0.ip_lists.0
  status      = "ENABLE"
}
