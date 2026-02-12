variable "install_config" {
  type = string
}

variable "routing_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-traefik
job "traefik" {
  datacenters = ["dc1"]
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "system"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "!="
    value     = "day1"
  }

  group "traefik" {
    network {
      port "web" {
        static = 80
      }
      port "webSecure" {
        static = 443
      }
      port "traefik" {
        static = 8080
      }
    }

    service {
      provider = "consul"
      name     = "traefik-${attr.unique.hostname}"
      port     = "webSecure"

      check {
        type           = "http"
        path           = "/ping"
        port           = "traefik"
        interval       = "180s"
        timeout        = "2s"
        initial_status = "passing"
      }

      # traffic path: haproxy.vyos -(tcp route)-> 
      #   traefik.day1 -[http route: decrypt(traefik.day2.sololab) & re-encrypt(server transport: traefik-day2.service.consul)]-> 
      #   traefik.day2 -[http route: decrypt(*.service.sololab)]-> app
      tags = [
        "metrics-exposing-blackbox",
        "metrics-exposing-general",
        "log",

        "traefik.enable=true",
        "traefik.http.routers.traefik-${attr.unique.hostname}-redirect.entryPoints=web",
        "traefik.http.routers.traefik-${attr.unique.hostname}-redirect.rule=Host(`traefik.${attr.unique.hostname}.sololab`)",
        "traefik.http.routers.traefik-${attr.unique.hostname}-redirect.middlewares=toHttps@file",

        "traefik.http.routers.traefik-${attr.unique.hostname}.entryPoints=webSecure",
        "traefik.http.routers.traefik-${attr.unique.hostname}.rule=Host(`traefik.${attr.unique.hostname}.sololab`)",
        "traefik.http.routers.traefik-${attr.unique.hostname}.tls.certresolver=internal",

        "traefik.http.services.traefik-${attr.unique.hostname}.loadbalancer.server.scheme=https",
        "traefik.http.services.traefik-${attr.unique.hostname}.loadbalancer.server.port=443",
        "traefik.http.services.traefik-${attr.unique.hostname}.loadBalancer.serversTransport=consul-service@file",
      ]

      meta {
        prom_blackbox_scheme            = "https"
        prom_blackbox_address           = "traefik-${attr.unique.hostname}.service.consul"
        prom_blackbox_health_check_path = "metrics"

        prom_target_scheme            = "https"
        prom_target_address           = "traefik-${attr.unique.hostname}.service.consul"
        prom_target_health_check_path = "metrics"
        prom_target_metrics_path      = "metrics"
      }
    }

    # volume "certs" {
    #   type            = "csi"
    #   source          = "traefik-acme"
    #   read_only       = false
    #   attachment_mode = "file-system"
    #   access_mode     = "multi-node-multi-writer"
    # }

    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "traefik" {
      driver = "podman"

      config {
        image = "zot.day0.sololab/library/traefik:v3.6.7"
        labels = {
          "traefik.enable"                                      = "true"
          "traefik.http.routers.dashboard-redirect.entrypoints" = "web"
          "traefik.http.routers.dashboard-redirect.rule"        = "(Host(`traefik.${attr.unique.hostname}.sololab`)||Host(`traefik-${attr.unique.hostname}.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "traefik.http.routers.dashboard-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.dashboard-redirect.service"     = "api@internal"

          "traefik.http.routers.dashboard.entryPoints" = "webSecure"
          "traefik.http.routers.dashboard.tls"         = "true"
          "traefik.http.routers.dashboard.rule"        = "(Host(`traefik.${attr.unique.hostname}.sololab`)||Host(`traefik-${attr.unique.hostname}.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
          "traefik.http.routers.dashboard.service"     = "api@internal"
          "traefik.http.routers.dashboard.middlewares" = "userPass@file"

          # https://community.traefik.io/t/api-not-accessible-when-traefik-in-host-network-mode/13321/2,
          "traefik.http.services.dashboard.loadbalancer.server.port" = "443"

          "traefik.http.routers.metrics.entryPoints" = "webSecure"
          "traefik.http.routers.metrics.tls"         = "true"
          "traefik.http.routers.metrics.rule"        = "(Host(`traefik.${attr.unique.hostname}.sololab`)||Host(`traefik-${attr.unique.hostname}.service.consul`)) && PathPrefix(`/metrics`)"
          "traefik.http.routers.metrics.service"     = "prometheus@internal"
        }
        network_mode = "host"

        security_opt = [
          "label=type:spc_t",
        ]

        # https://github.com/traefik/traefik/blob/v3.6.7/Dockerfile
        # https://doc.traefik.io/traefik/reference/install-configuration/boot-environment/#configuration-file
        command = "--configFile=/local/install/install.traefik.yaml"

        # in order to make template file content able to refresh in container environment,
        # use dir path which provide by nomad (/local, /secrets)
        # workload can only access templates rendered into the NOMAD_ALLOC_DIR, NOMAD_TASK_DIR, or NOMAD_SECRETS_DIR.
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#template-destinations
        volumes = [
          "local/hosts:/etc/hosts",
          # "local/install.traefik.yaml:/etc/traefik/traefik.yml",
          # "local/routing.traefik.yaml:/etc/traefik/dynamic/routing.yml",
          # "secrets/ca.crt:/etc/traefik/tls/ca.crt",
          # "secrets/consul.crt:/etc/traefik/tls/consul.crt",
          # "secrets/consul.key:/etc/traefik/tls/consul.key",
          "/run/podman/podman.sock:/var/run/docker.sock"
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        TZ = "Asia/Shanghai"
        # https://doc.traefik.io/traefik/https/acme/#casystemcertpool
        # LEGO_CA_CERTIFICATES     = "/etc/traefik/tls/ca.crt"
        LEGO_CA_CERTIFICATES     = "/secrets/tls/ca.crt"
        LEGO_CA_SYSTEM_CERT_POOL = "true"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        data        = var.install_config
        destination = "local/install/install.traefik.yaml"
      }

      template {
        data        = var.routing_config
        destination = "local/routing/routing.traefik.yaml"
      }

      template {
        data        = <<-EOF
        127.0.0.1       localhost localhost.localdomain
        ::1             localhost localhost.localdomain
        EOF
        destination = "local/hosts"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/*.service.consul" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/tls/ca.crt"
        change_mode = "restart"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/*.service.consul" }}{{ .Data.data.cert }}{{ end }}
        EOF
        destination = "secrets/tls/consul.crt"
        change_mode = "restart"
      }

      template {
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/*.service.consul" }}{{ .Data.data.private_key }}{{ end }}
        EOF
        destination = "secrets/tls/consul.key"
        change_mode = "restart"
      }

      vault {}

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      # volume_mount {
      #   volume      = "certs"
      #   destination = "/mnt/acmeStorage"
      # }

      restart {
        attempts = 3
        delay    = "10s"
      }

    }
  }
}