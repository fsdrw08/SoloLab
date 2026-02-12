locals {
  bookmarks = <<-EOH
  {{- range services }}
  {{- range service .Name }}
  {{- if (contains "behind_pgbouncer" .Tags) }}
  host = "{{ index .ServiceMeta "pgBouncerHost" }}"
  port = 6432
  sslmode = "require"
  database = "{{ index .ServiceMeta "dbName" }}"
  user = "{{ index .ServiceMeta "dbUser" }}"
  {{- $dbName := index .ServiceMeta "dbName" }}
  password = "{{ with secret (printf "kvv2_pgsql/data/%s" $dbName) }}{{ .Data.data.user_password }}{{ end }}"
  {{ printf "\n\n" }}
  {{- end }}
  {{- end }}
  {{- end }}
  EOH
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "pgweb" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "pgweb" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "pgweb" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "pgweb"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 8081
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(pgweb.day2.sololab) & re-encrypt(server transport(pgweb.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.pgweb-redirect.entryPoints=web",
          "traefik.http.routers.pgweb-redirect.rule=Host(`pgweb.day2.sololab`)",
          "traefik.http.routers.pgweb-redirect.middlewares=toHttps@file",

          "traefik.http.routers.pgweb.entryPoints=webSecure",
          "traefik.http.routers.pgweb.rule=Host(`pgweb.day2.sololab`)",
          "traefik.http.routers.pgweb.tls.certresolver=internal",

          "traefik.http.services.pgweb.loadbalancer.server.scheme=https",
          "traefik.http.services.pgweb.loadbalancer.server.port=443",
          "traefik.http.services.pgweb.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "pgweb.day2.sololab"
          prom_blackbox_health_check_path = ""
        }
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/sosedoff/pgweb:0.17.0"
        labels = {
          "traefik.enable"                                  = "true"
          "traefik.http.routers.pgweb-redirect.entrypoints" = "web"
          "traefik.http.routers.pgweb-redirect.rule"        = "(Host(`pgweb.day2.sololab`)||Host(`pgweb.service.consul`))"
          "traefik.http.routers.pgweb-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.pgweb-redirect.service"     = "pgweb"

          "traefik.http.routers.pgweb.entryPoints" = "webSecure"
          "traefik.http.routers.pgweb.rule"        = "(Host(`pgweb.day2.sololab`)||Host(`pgweb.service.consul`))"
          "traefik.http.routers.pgweb.tls"         = "true"
          "traefik.http.routers.pgweb.service"     = "pgweb"

          "traefik.http.services.pgweb.loadbalancer.server.port" = "8081"
        }
        args = [
          "--bookmarks-dir=/local/bookmark.d",
          # "--metrics",
        ]
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 64
      }

      dynamic "template" {
        for_each = split("\n\n", local.bookmarks)

        content {
          data        = template.value
          destination = "local/bookmark.d/${template.key}.toml"
        }
      }

      template {
        data = local.bookmarks

        destination = "local/test.txt"
      }

      vault {}

    }
  }
}