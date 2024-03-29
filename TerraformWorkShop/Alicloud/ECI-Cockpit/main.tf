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

data "alicloud_alidns_domains" "domain" {
  domain_name_regex = var.domain_name_regex
}

data "alicloud_nas_file_systems" "nas_fs" {
  description_regex = var.nas_file_system_desc_regex
}

data "alicloud_nas_mount_targets" "nas_mnt" {
  file_system_id = data.alicloud_nas_file_systems.nas_fs.systems.0.id
  vpc_id         = data.alicloud_vpcs.vpc.vpcs.0.id
  vswitch_id     = data.alicloud_vswitches.vsw.vswitches.0.id
}

resource "alicloud_eci_container_group" "eci" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  zone_id           = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id
  security_group_id = data.alicloud_security_groups.sg.groups.0.id

  container_group_name   = var.eci_group_name
  instance_type          = var.ecs_instance_type
  restart_policy         = var.eci_restart_policy
  auto_match_image_cache = var.eci_auto_img_cache

  containers {
    name              = var.eci_group_name
    image             = var.eci_image_uri
    image_pull_policy = "IfNotPresent"
    # Cockpit can be configured via /etc/cockpit/cockpit.conf. 
    # If $XDG_CONFIG_DIRS is set, then the first path containing a ../cockpit/cockpit.conf is used instead. 
    # https://cockpit-project.org/guide/latest/cockpit.conf.5.html
    # environment_vars {
    #   key   = "XDG_CONFIG_DIRS"
    #   value = "/mnt/.config"
    # }

    # https://github.com/cockpit-project/cockpit/blob/c05f1bc8fda75e7c3e1a6b4716a0be24ce5da8c7/containers/ws/Dockerfile
    commands = [
      "/bin/bash",
      "-c",
      <<-EOT
      cp /mnt/cockpit/..data/cockpit.conf /container/default-bastion.conf;
      /container/label-run --no-tls --port=${data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port};
      EOT
    ]
    # https://cockpit-project.org/guide/latest/cockpit-ws.8
    # args = [
    #   "--no-tls",
    #   "--port=${data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port}"
    # ]

    ports {
      port     = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
      protocol = "TCP"
    }

    liveness_probe {
      period_seconds        = "120"
      initial_delay_seconds = "60"
      success_threshold     = "1"
      failure_threshold     = "5"
      timeout_seconds       = "10"
      http_get {
        scheme = "HTTP"
        port   = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
        path   = "/"
      }
    }

    volume_mounts {
      name       = "cockpit-cm-conf"
      mount_path = "/mnt/cockpit"
    }

    volume_mounts {
      name       = "nfs-root"
      mount_path = "/mnt"
    }
  }

  volumes {
    name = "cockpit-cm-conf"
    type = "ConfigFileVolume"
    config_file_volume_config_file_to_paths {
      content = base64encode(
        templatefile("cockpit.conf", {
          FQDN = "${var.subdomain}.${data.alicloud_alidns_domains.domain.domains.0.domain_name}"
        })
      )
      path = "cockpit.conf"
    }
  }

  volumes {
    name              = "nfs-root"
    type              = "NFSVolume"
    nfs_volume_path   = "/"
    nfs_volume_server = data.alicloud_nas_mount_targets.nas_mnt.targets.0.mount_target_domain
  }

  # https://help.aliyun.com/document_detail/65415.html
  dns_config {
    name_servers = [
      "100.100.2.136",
      "100.100.2.138",
    ]
  }
}

# https://github.com/hatlonely/notebook/blob/f4dd810dc6032d4b04e76455835cbcd1840fec7a/terraform/code/alicloud/best-practise/2-eci-web-service/slb.tf#L17
resource "alicloud_slb_server_group" "slb_svr_group" {
  name             = var.eci_group_name
  load_balancer_id = data.alicloud_slb_load_balancers.slb.balancers.0.id
}

resource "alicloud_slb_server_group_server_attachment" "slb_attach" {
  server_group_id = alicloud_slb_server_group.slb_svr_group.id
  server_id       = alicloud_eci_container_group.eci.id
  port            = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
}

resource "alicloud_slb_rule" "slb_rule" {
  depends_on       = [alicloud_slb_domain_extension.slb_dext]
  load_balancer_id = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port    = 443
  name             = var.eci_group_name
  domain           = "${var.subdomain}.${data.alicloud_alidns_domains.domain.domains.0.domain_name}"
  server_group_id  = alicloud_slb_server_group.slb_svr_group.id
}

resource "alicloud_slb_domain_extension" "slb_dext" {
  load_balancer_id      = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port         = 443
  domain                = "${var.subdomain}.${data.alicloud_alidns_domains.domain.domains.0.domain_name}"
  server_certificate_id = data.alicloud_slb_server_certificates.slb_cert.certificates.0.id
}

resource "alicloud_alidns_record" "record" {
  domain_name = data.alicloud_alidns_domains.domain.domains.0.domain_name
  rr          = var.subdomain
  type        = "A"
  value       = data.alicloud_nat_gateways.ngw.gateways.0.ip_lists.0
  status      = "ENABLE"
}
