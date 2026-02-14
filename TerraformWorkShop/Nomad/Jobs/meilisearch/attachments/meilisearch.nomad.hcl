variable "config" {
  type = string
}

variable "master_key" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "meilisearch" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "meilisearch" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "meilisearch" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "meilisearch-${attr.unique.hostname}"
        # need to set address_mode to "host" to use day1 traefik's server transport
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 7700
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day1 -[http route: decrypt(meilisearch.day2.sololab) & re-encrypt(server transport(meilisearch-day2.service.consul)) & ]-> 
        #   traefik.day2 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.meilisearch-redirect.entryPoints=web",
          "traefik.http.routers.meilisearch-redirect.rule=Host(`meilisearch.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.meilisearch-redirect.middlewares=toHttps@file",

          "traefik.http.routers.meilisearch.entryPoints=webSecure",
          "traefik.http.routers.meilisearch.rule=Host(`meilisearch.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.meilisearch.tls.certresolver=internal",

          "traefik.http.services.meilisearch.loadbalancer.server.scheme=https",
          "traefik.http.services.meilisearch.loadbalancer.server.port=443",
          "traefik.http.services.meilisearch.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "meilisearch-${attr.unique.hostname}.service.consul"
          prom_blackbox_health_check_path = "/health"

          prom_target_scheme       = "https"
          prom_target_address      = "meilisearch-${attr.unique.hostname}.service.consul"
          prom_target_metrics_path = "metrics"
        }
      }

      driver = "podman"
      config {
        image = "zot.day0.sololab/getmeili/meilisearch:v1.35.0"
        labels = {
          "traefik.enable"                                        = "true"
          "traefik.http.routers.meilisearch-redirect.entrypoints" = "web"
          "traefik.http.routers.meilisearch-redirect.rule"        = "(Host(`meilisearch.${attr.unique.hostname}.sololab`)||Host(`meilisearch-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.meilisearch-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.meilisearch-redirect.service"     = "meilisearch"

          "traefik.http.routers.meilisearch.entryPoints" = "webSecure"
          "traefik.http.routers.meilisearch.rule"        = "(Host(`meilisearch.${attr.unique.hostname}.sololab`)||Host(`meilisearch-${attr.unique.hostname}.service.consul`))"
          "traefik.http.routers.meilisearch.tls"         = "true"
          "traefik.http.routers.meilisearch.service"     = "meilisearch"

          "traefik.http.middlewares.meilisearch-metrics-AuthHeader.headers.customRequestHeaders.Authorization" = "Bearer ${var.master_key}"
          "traefik.http.routers.meilisearch-metrics.entryPoints"                                               = "webSecure"
          "traefik.http.routers.meilisearch-metrics.rule"                                                      = "(Host(`meilisearch.${attr.unique.hostname}.sololab`)||Host(`meilisearch-${attr.unique.hostname}.service.consul`)) && Path(`/metrics`)"
          "traefik.http.routers.meilisearch-metrics.middlewares"                                               = "meilisearch-metrics-AuthHeader@docker"
          "traefik.http.routers.meilisearch-metrics.tls"                                                       = "true"
          "traefik.http.routers.meilisearch-metrics.service"                                                   = "meilisearch"

          "traefik.http.services.meilisearch.loadbalancer.server.port" = "7700"
        }
        args = [
          "/bin/meilisearch",
          "--config-file-path=/local/config.toml",
        ]
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 200
      }

      # https://www.meilisearch.com/docs/learn/self_hosted/configure_meilisearch_at_launch
      # https://www.meilisearch.com/docs/learn/self_hosted/configure_meilisearch_at_launch#all-instance-options
      template {
        data        = var.config
        destination = "local/config.toml"
      }
      vault {}

      # https://github.com/meilisearch/meilisearch/blob/v1.35.0/Dockerfile#L40
      volume_mount {
        volume        = "meilisearch"
        destination   = "/meili_data"
        selinux_label = "Z"
      }
    }
    volume "meilisearch" {
      type            = "host"
      source          = "meilisearch"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}