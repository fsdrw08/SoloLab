variable "alloy_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "alloy" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "alloy" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "alloy" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "alloy-${attr.unique.hostname}"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          port           = 12345
          type           = "http"
          path           = "/-/ready"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",

          "traefik.enable=true",
          "traefik.http.routers.alloy-${attr.unique.hostname}-redirect.entryPoints=web",
          "traefik.http.routers.alloy-${attr.unique.hostname}-redirect.rule=(Host(`alloy.${attr.unique.hostname}.sololab`)||Host(`alloy-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.alloy-${attr.unique.hostname}-redirect.middlewares=toHttps@file",

          "traefik.http.routers.alloy-${attr.unique.hostname}.entryPoints=webSecure",
          "traefik.http.routers.alloy-${attr.unique.hostname}.rule=(Host(`alloy.${attr.unique.hostname}.sololab`)||Host(`alloy-${attr.unique.hostname}.service.consul`))",
          "traefik.http.routers.alloy-${attr.unique.hostname}.tls=true",

          "traefik.http.services.alloy-${attr.unique.hostname}.loadbalancer.server.scheme=https",
          "traefik.http.services.alloy-${attr.unique.hostname}.loadbalancer.server.port=443",
          "traefik.http.services.alloy-${attr.unique.hostname}.loadBalancer.serversTransport=consul-service@file",
        ]
      }

      user = "root"

      driver = "podman"
      config {
        network_mode = "host"
        image = "zot.day0.sololab/grafana/alloy:v1.11.3"
        args = [
          "run",
          "/etc/alloy/config.alloy",
          "--server.http.listen-addr=127.0.0.1:12345",
          "--storage.path=${NOMAD_ALLOC_DIR}/data",
        ]
        labels = {
          "traefik.enable"                                                          = "true"
          "traefik.http.routers.alloy-${attr.unique.hostname}-redirect.entrypoints" = "web"
          "traefik.http.routers.alloy-redirect.rule"                                = "(Host(`alloy.${attr.unique.hostname}.sololab`)||Host(`alloy-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.alloy-redirect.middlewares"                         = "toHttps@file"
          "traefik.http.routers.alloy.service"                                      = "alloy"

          "traefik.http.routers.alloy.entrypoints" = "webSecure"
          "traefik.http.routers.alloy.rule"        = "(Host(`alloy.${attr.unique.hostname}.sololab`)||Host(`alloy-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.alloy.tls"         = "true"
          "traefik.http.routers.alloy.service"     = "alloy"

          "traefik.http.services.alloy.loadbalancer.server.port" = "12345"
        }
        hostname = "${attr.unique.hostname}"
        security_opt = [
          "label=type:spc_t",
        ]

        volumes = [
          "local/config.alloy:/etc/alloy/config.alloy",
          "/var/lib/nomad/alloc:/var/lib/nomad/alloc:ro",
          "/:/host:ro,rslave",
        ]

      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      template {
        data        = var.alloy_config
        destination = "local/config.alloy"
      }
    }
  }
}