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

  init_containers {
    name = "mkdir"
    # https://hub.docker.com/r/bitnami/os-shell/tags
    image             = "docker.io/library/alpine:latest"
    image_pull_policy = "IfNotPresent"
    commands = [
      "/bin/sh",
      "-c",
      <<-EOT
      mkdir -p /mnt/jenkins/plugins-loading/ /mnt/jenkins/home/ /mnt/jenkins/plugins-storage/ && \
      id && \
      chown 1000:1000 /mnt/jenkins/plugins-loading/ && \
      chown 1000:1000 /mnt/jenkins/home/ && \
      chown 1000:1000 /mnt/jenkins/plugins-storage/
      EOT
    ]
    volume_mounts {
      name       = "nfs-root"
      mount_path = "/mnt"
    }
  }
  init_containers {
    name              = "provision"
    image             = var.eci_image_uri
    image_pull_policy = "IfNotPresent"
    commands = [
      "sh",
      "/var/jenkins_config/apply_config.sh"
    ]
    environment_vars {
      key   = "JENKINS_UC"
      value = "https://mirrors.aliyun.com/jenkins/updates/"
    }
    environment_vars {
      key   = "JENKINS_UC_DOWNLOAD"
      value = "https://mirrors.aliyun.com/jenkins"
    }
    volume_mounts {
      name       = "jenkins-pvc-home"
      mount_path = "/var/jenkins_home"
    }
    volume_mounts {
      name       = "jenkins-cm-provision"
      mount_path = "/var/jenkins_config"
    }
    # init container download plugins into this folder
    # this is where Jenkins normally looks for plugins
    volume_mounts {
      name       = "jenkins-pvc-plugins-loading"
      mount_path = "/usr/share/jenkins/ref/plugins"
    }
    # then move to this folder
    volume_mounts {
      name       = "jenkins-pvc-plugins-storage"
      mount_path = "/var/jenkins_plugins"
    }
    volume_mounts {
      name       = "jenkins-ed-tmp"
      mount_path = "/tmp"
    }
  }

  containers {
    name              = "jenkins"
    image             = var.eci_image_uri
    image_pull_policy = "IfNotPresent"
    args = [
      "--httpPort=${data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port}"
    ]

    environment_vars {
      key   = "SECRETS"
      value = "/run/secrets/additional"
    }
    environment_vars {
      key   = "POD_NAME"
      value = var.eci_group_name
    }
    environment_vars {
      key   = "CASC_RELOAD_TOKEN"
      value = var.eci_group_name
    }
    environment_vars {
      key   = "JENKINS_OPTS"
      value = "--webroot=/var/jenkins_cache/war"
    }
    environment_vars {
      key   = "CASC_JENKINS_CONFIG"
      value = "/var/jenkins_home/casc_configs"
    }

    ports {
      port     = data.alicloud_slb_listeners.slb_listener.slb_listeners.0.backend_port
      protocol = "TCP"
    }
    ports {
      port     = var.jenkins_agent_listener
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
        port   = var.eci_port
        path   = "login"
      }
    }

    volume_mounts {
      name       = "jenkins-pvc-home"
      mount_path = "/var/jenkins_home"
    }
    volume_mounts {
      name       = "jenkins-cm-provision"
      mount_path = "/var/jenkins_config"
      read_only  = true
    }
    volume_mounts {
      name       = "jenkins-cm-jcasc"
      mount_path = "/var/jenkins_home/casc_configs"
      read_only  = true
    }
    volume_mounts {
      name       = "jenkins-pvc-plugins-storage"
      mount_path = "/usr/share/jenkins/ref/plugins"
    }
    volume_mounts {
      name       = "jenkins-sec-secrets"
      mount_path = "/run/secrets/additional"
      read_only  = true
    }
    volume_mounts {
      name       = "jenkins-ed-cache"
      mount_path = "/var/jenkins_cache"
    }
    volume_mounts {
      name       = "jenkins-ed-tmp"
      mount_path = "/tmp"
    }
  }

  containers {
    name              = "reload-jcasc"
    image             = "docker.io/dockerpinata/inotify-tools:2.1"
    image_pull_policy = "IfNotPresent"
    environment_vars {
      key   = "POD_NAME"
      value = var.eci_group_name
    }
    commands = [
      "/bin/sh",
      "-c"
    ]
    # https://www.reddit.com/r/Terraform/comments/y0d6os/how_to_write_list_of_multiline_string/
    args = [
      <<-EOT
        inotifywait -mr -e modify /var/jenkins_home/casc_configs | while read MODIFY     
          do
            wget --post-data casc-reload-token=$POD_NAME http://localhost:8080/reload-configuration-as-code/
          done
      EOT
      ,
    ]
    volume_mounts {
      name       = "jenkins-cm-jcasc"
      mount_path = "/var/jenkins_home/casc_configs"
    }
  }

  # https://help.aliyun.com/zh/eci/user-guide/mount-a-configfile-volume
  # https://github.com/Explorer1092/terraform-x-interactsh/blob/c25f9fbead278040a0983851e1aceb6e5dcd447f/main.tf#L79
  volumes {
    name = "jenkins-sec-secrets"
    type = "ConfigFileVolume"
    config_file_volume_config_file_to_paths {
      content = base64encode("admin")
      path    = "jenkins-admin-user"
    }
    config_file_volume_config_file_to_paths {
      content = base64encode(var.jenkins_admin_password)
      path    = "jenkins-admin-password"
    }
  }
  volumes {
    name = "jenkins-cm-provision"
    type = "ConfigFileVolume"
    config_file_volume_config_file_to_paths {
      content = base64encode(file("apply_config.sh"))
      path    = "apply_config.sh"
    }
    config_file_volume_config_file_to_paths {
      content = base64encode(file("plugins.txt"))
      path    = "plugins.txt"
    }
  }
  volumes {
    name = "jenkins-cm-jcasc"
    type = "ConfigFileVolume"
    config_file_volume_config_file_to_paths {
      content = base64encode(templatefile(var.jenkins_casc_default, {
        subdomain   = var.subdomain,
        root_domain = var.root_domain
      }))
      path = var.jenkins_casc_default
    }
    dynamic "config_file_volume_config_file_to_paths" {
      # https://stackoverflow.com/questions/59161749/loop-over-a-map-and-skip-empty-items
      for_each = {
        for casc in var.jenkins_casc_addition :
        casc.file => casc if casc.file != ""
      }
      content {
        content = base64encode(file(config_file_volume_config_file_to_paths.value.file))
        path    = config_file_volume_config_file_to_paths.value.file
      }
    }
  }
  # https://github.com/Explorer1092/terraform-x-eci_docker_register/blob/2cb4a8ec8d8a68c843cc2c8a576d9c60e6477fef/main.tf#L68
  volumes {
    name              = "nfs-root"
    type              = "NFSVolume"
    nfs_volume_path   = "/"
    nfs_volume_server = data.alicloud_nas_mount_targets.nas_mnt.targets.0.mount_target_domain
  }
  volumes {
    name              = "jenkins-pvc-home"
    type              = "NFSVolume"
    nfs_volume_path   = "/jenkins/home/"
    nfs_volume_server = data.alicloud_nas_mount_targets.nas_mnt.targets.0.mount_target_domain
  }
  volumes {
    name              = "jenkins-pvc-plugins-loading"
    type              = "NFSVolume"
    nfs_volume_path   = "/jenkins/plugins-loading/"
    nfs_volume_server = data.alicloud_nas_mount_targets.nas_mnt.targets.0.mount_target_domain
  }
  volumes {
    name              = "jenkins-pvc-plugins-storage"
    type              = "NFSVolume"
    nfs_volume_path   = "/jenkins/plugins-storage/"
    nfs_volume_server = data.alicloud_nas_mount_targets.nas_mnt.targets.0.mount_target_domain
  }
  volumes {
    name = "jenkins-ed-cache"
    type = "EmptyDirVolume"
  }
  volumes {
    name = "jenkins-ed-tmp"
    type = "EmptyDirVolume"
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
  domain           = "${var.subdomain}.${var.root_domain}"
  server_group_id  = alicloud_slb_server_group.slb_svr_group.id
}

resource "alicloud_slb_domain_extension" "slb_dext" {
  load_balancer_id      = data.alicloud_slb_load_balancers.slb.balancers.0.id
  frontend_port         = 443
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
