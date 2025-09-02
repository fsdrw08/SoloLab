variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-whoami
job "nfs-ganesha" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    value     = "day1"
  }

  group "nfs-ganesha" {
    network {
      port "nfs" {
        static = 2049
      }
    }

    service {
      provider = "consul"
      name     = "nfs-ganesha"
      port     = "nfs"

      check {
        type     = "tcp"
        port     = "nfs"
        interval = "10s"
        timeout  = "2s"
      }

    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    # https://github.com/hectorm/docker-nfs-ganesha/blob/master/compose.yaml
    task "nfs-ganesha" {
      driver = "podman"

      config {
        image = "zot.day0.sololab/hectorm/nfs-ganesha:v9"
        cap_add = [
          "CHOWN",
          "DAC_OVERRIDE",
          "DAC_READ_SEARCH",
          "FOWNER",
          "FSETID",
          "SETGID",
          "SETUID",
          "SYS_RESOURCE",
        ]
        cap_drop = [
          "ALL"
        ]
        network_mode = "host"
        # ports        = ["web", "webSecure", "whoami"]
        volumes = [
          "local/ganesha.conf:/etc/ganesha/ganesha.conf:ro",
          "/var/mnt/data/nfs:/export"
        ]

      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }

      template {
        change_mode = "restart"
        data        = var.config
        destination = "local/ganesha.conf"
      }
    }
  }
}