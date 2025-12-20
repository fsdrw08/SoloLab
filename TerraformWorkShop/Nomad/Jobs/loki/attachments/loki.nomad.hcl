variable "loki_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-loki
job "loki" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "loki" {

    volume "data" {
      type            = "csi"
      source          = "loki-data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "loki" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "loki"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 3100
          type           = "http"
          path           = "/ready"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "exporter",

          "traefik.enable=true",
          "traefik.tcp.routers.loki.entryPoints=webSecure",
          "traefik.tcp.routers.loki.rule=HostSNI(`loki.day2.sololab`)",
          "traefik.tcp.routers.loki.tls.passthrough=true",
          "traefik.tcp.services.loki.loadbalancer.server.port=443",
        ]
      }

      driver = "podman"

      config {
        image = "zot.day0.sololab/grafana/loki:3.6.3"
        labels = {
          "traefik.enable"                                 = "true"
          "traefik.http.routers.loki-redirect.entrypoints" = "web"
          "traefik.http.routers.loki-redirect.rule"        = "Host(`loki.day2.sololab`)"
          "traefik.http.routers.loki-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.loki-redirect.service"     = "loki"

          "traefik.http.routers.loki.entrypoints"      = "webSecure"
          "traefik.http.routers.loki.tls.certresolver" = "internal"
          "traefik.http.routers.loki.rule"             = "Host(`loki.day2.sololab`)"

          "traefik.http.services.loki.loadbalancer.server.port" = "3100"
        }

        ## userns can only apply when network_mode is not host
        userns = "keep-id:uid=10001,gid=10001"

        volumes = [
          "local/local-config.yaml:/etc/loki/local-config.yaml",
          "secrets/ca.crt:/etc/loki/certs/ca.crt",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ                 = "Asia/Shanghai"
        GF_SERVER_DOMAIN   = "loki.day2.sololab"
        GF_SERVER_ROOT_URL = "https://loki.day2.sololab"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        data        = var.loki_config
        destination = "local/local-config.yaml"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/ca.crt"
        change_mode = "restart"
      }

      vault {}

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume      = "data"
        destination = "/var/loki"
      }
    }
  }
}