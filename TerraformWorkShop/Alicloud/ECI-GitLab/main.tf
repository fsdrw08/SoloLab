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


resource "alicloud_eci_container_group" "default" {
  resource_group_id = data.alicloud_resource_manager_resource_groups.rg.groups.0.id
  zone_id           = data.alicloud_vswitches.vsw.vswitches.0.zone_id
  vswitch_id        = data.alicloud_vswitches.vsw.vswitches.0.id
  security_group_id = data.alicloud_security_groups.sg.groups.0.id

  container_group_name = var.eci_group_name
  instance_type        = var.ecs_instance_type
  restart_policy       = var.eci_restart_policy

  containers {
    image             = var.eci_image_uri
    name              = "gitlab"
    image_pull_policy = "IfNotPresent"

    ports {
      port     = 80
      protocol = "TCP"
    }
    ports {
      port     = 22
      protocol = "TCP"
    }

    environment_vars {
      key   = "GITLAB_OMNIBUS_CONFIG"
      value = var.GITLAB_OMNIBUS_CONFIG
    }

    liveness_probe {
      initial_delay_seconds = "180"
      period_seconds        = "60"
      success_threshold     = "1"
      failure_threshold     = "3"
      timeout_seconds       = "2"
      http_get {
        scheme = "HTTP"
        port   = 80
        path   = "/"
      }
    }

    volume_mounts {
      name       = "config"
      mount_path = "/etc/gitlab"
      read_only  = false
    }
    volume_mounts {
      name       = "logs"
      mount_path = "/var/log/gitlab"
      read_only  = false
    }
    volume_mounts {
      name       = "data"
      mount_path = "/var/opt/gitlab"
      read_only  = false
    }
    volume_mounts {
      name       = "dshm"
      mount_path = "/dev/shm"
      read_only  = false
    }
  }

  volumes {
    name = "config"
    type = "NFSVolume"
  }
  volumes {
    name = "empty2"
    type = "NFSVolume"
  }
}
