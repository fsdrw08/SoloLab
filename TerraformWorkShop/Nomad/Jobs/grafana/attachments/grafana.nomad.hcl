variable "grafana_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "grafana" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "grafana" {

    volume "data" {
      type            = "csi"
      source          = "grafana-data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
    }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "grafana" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "grafana"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 3000
          type           = "http"
          path           = "/api/health"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "exporter",

          "traefik.enable=true",
          "traefik.http.routers.grafana-redirect.entryPoints=web",
          "traefik.http.routers.grafana-redirect.rule=Host(`grafana.day2.sololab`)",
          "traefik.http.routers.grafana-redirect.middlewares=toHttps@file",

          "traefik.http.routers.grafana.entryPoints=webSecure",
          "traefik.http.routers.grafana.rule=Host(`grafana.day2.sololab`)",
          "traefik.http.routers.grafana.tls.certresolver=internal",

          "traefik.http.services.grafana.loadbalancer.server.scheme=https",
          "traefik.http.services.grafana.loadbalancer.server.port=443",
          "traefik.http.services.grafana.loadBalancer.serversTransport=consul-service@file",
        ]
      }

      driver = "podman"

      config {
        image = "zot.day0.sololab/grafana/grafana:12.3.1"
        labels = {
          "traefik.enable"                                    = "true"
          "traefik.http.routers.grafana-redirect.entrypoints" = "web"
          "traefik.http.routers.grafana-redirect.rule"        = "Host(`grafana.day2.sololab`)"
          "traefik.http.routers.grafana-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.grafana-redirect.service"     = "grafana"

          "traefik.http.routers.grafana.entrypoints" = "webSecure"
          "traefik.http.routers.grafana.rule"        = "Host(`grafana.day2.sololab`)"
          "traefik.http.routers.grafana.tls"         = "true"
          "traefik.http.routers.grafana.service"     = "grafana"

          "traefik.http.services.grafana.loadbalancer.server.port" = "3000"
        }

        ## userns can only apply when network_mode is not host
        userns = "keep-id:uid=472,gid=0"

        volumes = [
          "local/grafana.ini:/etc/grafana/grafana.ini",
          "secrets/ca.crt:/etc/grafana/certs/ca.crt",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ                 = "Asia/Shanghai"
        GF_SERVER_DOMAIN   = "grafana.day2.sololab"
        GF_SERVER_ROOT_URL = "https://grafana.day2.sololab"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        data        = var.grafana_config
        destination = "local/grafana.ini"
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
        destination = "/var/lib/grafana"
      }
    }
  }
}