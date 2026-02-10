variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "redis" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "redis" {
    network {
      port "redis" {
        static = 6379
      }
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "redis" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "redis-${attr.unique.hostname}"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          type           = "tcp"
          port           = "redis"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",
          "metrics-exposing-general",
        ]
        meta {
          scheme            = "https"
          address           = "prometheus-redis-exporter-${attr.unique.hostname}.service.consul"
          health_check_path = "scrape"
          metrics_path      = "scrape"
        }
      }

      user = "999:1000"

      driver = "podman"
      config {
        image = "zot.day0.sololab/library/redis:8.4.0"

        ports = [
          "redis",
        ]

        args = [
          "redis-server",
          "/local/server.conf",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ            = "Asia/Shanghai"
        REDISCLI_AUTH = "P@ssw0rd"
      }

      template {
        data        = var.config
        destination = "local/server.conf"
        change_mode = "restart"
      }

      template {
        data = <<-EOH
        user default off
        user exporter +client +ping +info +config|get +cluster|info +slowlog +latency +memory +select +get +scan +xinfo +type +pfcount +strlen +llen +scard +zcard +hlen +xlen on >exporter
        user admin on ~* +@all >P@ssw0rd
        user gitea on ~gitea:* +@all -REPLICAOF -CONFIG -DEBUG -SAVE -MONITOR -ACL -SHUTDOWN >gitea
        EOH

        destination = "secrets/acl.conf"
      }
      # vault {}

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume        = "redis"
        destination   = "/data"
        selinux_label = "Z"
      }
    }
    volume "redis" {
      type            = "host"
      source          = "redis"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}