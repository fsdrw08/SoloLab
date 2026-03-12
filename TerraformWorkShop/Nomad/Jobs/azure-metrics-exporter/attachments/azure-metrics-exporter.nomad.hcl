variable "prometheus_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "azure-metrics-exporter" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "azure-metrics-exporter" {
    task "azure-metrics-forwarder" {
      service {
        provider = "consul"
        name     = "azure-metrics-forwarder"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 9090
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(nexus3.day3.sololab) & re-encrypt(server transport(nexus3.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "log",

          # "traefik.enable=true",
          # "traefik.http.routers.azure-metrics-forwarder-redirect.entryPoints=web",
          # "traefik.http.routers.azure-metrics-forwarder-redirect.rule=Host(`azure-metrics-forwarder.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.azure-metrics-forwarder-redirect.middlewares=toHttps@file",

          # "traefik.http.routers.azure-metrics-forwarder.entryPoints=webSecure",
          # "traefik.http.routers.azure-metrics-forwarder.rule=Host(`azure-metrics-forwarder.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.azure-metrics-forwarder.tls.certresolver=internal",

          # "traefik.http.services.azure-metrics-forwarder.loadbalancer.server.scheme=https",
          # "traefik.http.services.azure-metrics-forwarder.loadbalancer.server.port=443",
          # "traefik.http.services.azure-metrics-forwarder.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "azure-metrics-exporter.service.consul"
        #   prom_blackbox_health_check_path = "/"

        #   # https://github.com/Wojciech512/NebulaOps-Observability-Platform-Master-s-thesis/blob/b6dd46df5f1245990b47d3153cc34d42a28a0b4f/prometheus.yml
        #   prom_target_scheme       = "https"
        #   prom_target_address      = "azure-metrics-exporter.service.consul"
        #   prom_target_metrics_path = "service/rest/metrics/prometheus"
        # }
      }

      driver = "podman"
      config {
        # https://github.com/prometheus/prometheus/blob/v3.10.0/Dockerfile
        image = "zot.day0.sololab/prometheus/prometheus:v3.10.0"
        labels = {
          "traefik.enable"                                                    = "true"
          "traefik.http.routers.azure-metrics-forwarder-redirect.entrypoints" = "web"
          "traefik.http.routers.azure-metrics-forwarder-redirect.rule"        = "Host(`azure-metrics-forwarder.service.consul`)"
          "traefik.http.routers.azure-metrics-forwarder-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.azure-metrics-forwarder.service"              = "azure-metrics-forwarder"

          "traefik.http.routers.azure-metrics-forwarder.entrypoints" = "webSecure"
          "traefik.http.routers.azure-metrics-forwarder.rule"        = "Host(`azure-metrics-forwarder.service.consul`)"
          "traefik.http.routers.azure-metrics-forwarder.tls"         = "true"
          "traefik.http.routers.azure-metrics-forwarder.service"     = "azure-metrics-forwarder"

          "traefik.http.services.azure-metrics-forwarder.loadbalancer.server.port" = "9090"
        }
        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--log.format=logfmt",
          "--log.level=info",
          "--storage.tsdb.path=/prometheus",
        ]

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        data = var.prometheus_config
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "local/prometheus.yml"
      }
      vault {}

      volume_mount {
        volume        = "azure-metrics-forwarder"
        destination   = "/prometheus"
        selinux_label = "Z"
      }
    }
    volume "azure-metrics-forwarder" {
      type            = "host"
      source          = "azure-metrics-forwarder"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }

    task "azure-metrics-exporter" {
      service {
        provider = "consul"
        name     = "azure-metrics-exporter"
        # need to set address_mode to "host" to use day1 traefik's server transport
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
        #   traefik.day1 -[http route: decrypt(nexus3.day3.sololab) & re-encrypt(server transport(nexus3.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "log",

          "traefik.enable=true",
          "traefik.http.routers.azure-metrics-exporter-redirect.entryPoints=web",
          "traefik.http.routers.azure-metrics-exporter-redirect.rule=Host(`azure-metrics-exporter.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.azure-metrics-exporter-redirect.middlewares=toHttps@file",

          "traefik.http.routers.azure-metrics-exporter.entryPoints=webSecure",
          "traefik.http.routers.azure-metrics-exporter.rule=Host(`azure-metrics-exporter.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.azure-metrics-exporter.tls.certresolver=internal",

          "traefik.http.services.azure-metrics-exporter.loadbalancer.server.scheme=https",
          "traefik.http.services.azure-metrics-exporter.loadbalancer.server.port=443",
          "traefik.http.services.azure-metrics-exporter.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "azure-metrics-exporter.service.consul"
        #   prom_blackbox_health_check_path = "/"

        #   # https://github.com/Wojciech512/NebulaOps-Observability-Platform-Master-s-thesis/blob/b6dd46df5f1245990b47d3153cc34d42a28a0b4f/prometheus.yml
        #   prom_target_scheme       = "https"
        #   prom_target_address      = "azure-metrics-exporter.service.consul"
        #   prom_target_metrics_path = "service/rest/metrics/prometheus"
        # }
      }

      driver = "podman"
      config {
        # https://github.com/webdevops/azure-metrics-exporter?tab=readme-ov-file#configuration
        image = "zot.day0.sololab/webdevops/azure-metrics-exporter:25.12.0"
        labels = {
          "traefik.enable"                                                   = "true"
          "traefik.http.routers.azure-metrics-exporter-redirect.entrypoints" = "web"
          "traefik.http.routers.azure-metrics-exporter-redirect.rule"        = "Host(`azure-metrics-exporter.service.consul`)"
          "traefik.http.routers.azure-metrics-exporter-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.azure-metrics-exporter.service"              = "azure-metrics-exporter"

          "traefik.http.routers.azure-metrics-exporter.entrypoints" = "webSecure"
          "traefik.http.routers.azure-metrics-exporter.rule"        = "Host(`azure-metrics-exporter.service.consul`)"
          "traefik.http.routers.azure-metrics-exporter.tls"         = "true"
          "traefik.http.routers.azure-metrics-exporter.service"     = "azure-metrics-exporter"

          "traefik.http.services.azure-metrics-exporter.loadbalancer.server.port" = "8080"
        }
      }

      resources {
        cpu    = 100
        memory = 128
      }

      template {
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        # https://github.com/webdevops/go-common/blob/main/azuresdk/README.md#authentication
        AZURE_TENANT_ID={{with secret "kvv2_others/data/azure-sp-cred_exporter"}}{{.Data.data.tenant_id}}{{end}}
        AZURE_CLIENT_ID={{with secret "kvv2_others/data/azure-sp-cred_exporter"}}{{.Data.data.client_id}}{{end}}
        AZURE_CLIENT_SECRET={{with secret "kvv2_others/data/azure-sp-cred_exporter"}}{{.Data.data.client_secret}}{{end}}
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
    }
  }
}