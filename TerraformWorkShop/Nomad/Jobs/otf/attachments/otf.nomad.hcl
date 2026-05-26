variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "otf" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "otf" {
    task "wait4x-postgresql" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
        args = [
          "postgresql",
          "${URL}",
        ]
      }
      template {
        # https://help.sonatype.com/en/install-nexus-repository-with-a-postgresql-database.html
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        URL=postgres://{{with secret "kvv2_pgsql/data/otf"}}{{.Data.data.user_name}}{{end}}:{{with secret "kvv2_pgsql/data/otf"}}{{.Data.data.user_password}}{{end}}@pgbouncer.service.consul:6432/otf?sslmode=require
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
    }

    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "otf" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "otf"
        # need to set address_mode to "host" to use day2 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 8080
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day2 -[http route: decrypt(otf.day4.sololab) & re-encrypt(server transport(otf.service.consul)) & ]-> 
        #   traefik.day3 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.otf-redirect.entryPoints=web",
          "traefik.http.routers.otf-redirect.rule=Host(`otf.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.otf-redirect.middlewares=toHttps@file",

          "traefik.http.routers.otf.entryPoints=webSecure",
          "traefik.http.routers.otf.rule=Host(`otf.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.otf.tls.certresolver=internal",

          "traefik.http.services.otf.loadbalancer.server.scheme=https",
          "traefik.http.services.otf.loadbalancer.server.port=443",
          "traefik.http.services.otf.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "otf.service.consul"
        #   prom_blackbox_health_check_path = "/health"

        #   prom_target_scheme       = "https"
        #   prom_target_address      = "otf.service.consul"
        #   prom_target_metrics_path = "metrics"
        # }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://github.com/leg100/otf/blob/v0.5.24/Dockerfile
        image = "zot.day1.sololab/leg100/otfd:0.5.24"
        labels = {
          "traefik.enable"                                = "true"
          "traefik.http.routers.otf-redirect.entrypoints" = "web"
          "traefik.http.routers.otf-redirect.rule"        = "(Host(`otf.day4.sololab`)||Host(`otf.service.consul`))"
          "traefik.http.routers.otf-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.otf-redirect.service"     = "otf"

          "traefik.http.routers.otf.entryPoints" = "webSecure"
          "traefik.http.routers.otf.rule"        = "(Host(`otf.day4.sololab`)||Host(`otf.service.consul`))"
          "traefik.http.routers.otf.tls"         = "true"
          "traefik.http.routers.otf.service"     = "otf"

          "traefik.http.services.otf.loadbalancer.server.port" = "8080"
        }
      }

      env {
        SSL_CERT_FILE = "/secrets/sololab.crt"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 600
      }

      template {
        change_mode = "restart"
        data        = var.config
        destination = "secrets/config.env"
        env         = true
      }
      template {
        change_mode = "noop"
        data        = <<-EOF
          {{ with secret " kvv2_certs/data/sololab_root " }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/sololab.crt"
      }
      vault {}

    }
  }
}