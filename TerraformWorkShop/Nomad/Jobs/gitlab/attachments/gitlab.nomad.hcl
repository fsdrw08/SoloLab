variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitlab" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "gitlab" {
    network {
      port "gitlab-ssh" {
        static = 2222
      }
    }

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
        URL=postgres://{{with secret "kvv2_pgsql/data/gitlab"}}{{.Data.data.user_name}}{{end}}:{{with secret "kvv2_pgsql/data/gitlab"}}{{.Data.data.user_password}}{{end}}@pgbouncer.service.consul:6432/gitlab?sslmode=require
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
    }


    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "gitlab" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitlab"
        # need to set address_mode to "host" to make this service resolve to host ip address in consul
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 3000
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }
        # traffic path: haproxy.vyos -(tcp route)-> 
        #   traefik.day2 -[http route: decrypt(meilisearch.day3.sololab) & re-encrypt(server transport(meilisearch-day3.service.consul)) & ]-> 
        #   traefik.day3 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.gitlab-redirect.entryPoints=web",
          "traefik.http.routers.gitlab-redirect.rule=Host(`gitlab.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitlab-redirect.middlewares=toHttps@file",

          "traefik.http.routers.gitlab.entryPoints=webSecure",
          "traefik.http.routers.gitlab.rule=Host(`gitlab.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitlab.tls.certresolver=internal",

          "traefik.http.services.gitlab.loadbalancer.server.scheme=https",
          "traefik.http.services.gitlab.loadbalancer.server.port=443",
          "traefik.http.services.gitlab.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "gitlab.service.consul"
        #   prom_blackbox_health_check_path = "/health"

        #   prom_target_scheme       = "https"
        #   prom_target_address      = "gitlab.service.consul"
        #   prom_target_metrics_path = "metrics"
        # }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/18.11.1+ee.0/docker/Dockerfile?ref_type=tags
        image = "zot.day1.sololab/gitlab/gitlab-ee:18.11.1-ee.0"
        labels = {
          "traefik.enable"                                   = "true"
          "traefik.http.routers.gitlab-redirect.entrypoints" = "web"
          "traefik.http.routers.gitlab-redirect.rule"        = "(Host(`gitlab.day4.sololab`)||Host(`gitlab.service.consul`))"
          "traefik.http.routers.gitlab-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.gitlab-redirect.service"     = "gitlab"

          "traefik.http.routers.gitlab.entryPoints" = "webSecure"
          "traefik.http.routers.gitlab.rule"        = "(Host(`gitlab.day4.sololab`)||Host(`gitlab.service.consul`))"
          "traefik.http.routers.gitlab.tls"         = "true"
          "traefik.http.routers.gitlab.service"     = "gitlab"

          "traefik.http.services.gitlab.loadbalancer.server.port" = "80"
        }
        ports = [
          "gitlab-ssh",
        ]
        volumes = [
          "local/gitlab.rb:/etc/gitlab/gitlab.rb",
          "secrets/sololab.ca.crt:/etc/gitlab/trusted-certs/sololab.ca.crt",
        ]
      }

      template {
        data        = <<-EOH
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOH
        destination = "secrets/sololab.ca.crt"
      }
      template {
        data        = var.config
        destination = "local/gitlab.rb"
      }
      vault {}

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 600
      }

      volume_mount {
        volume        = "gitlab"
        destination   = "/mnt"
        selinux_label = "Z"
      }
    }
    volume "gitlab" {
      type            = "csi"
      source          = "csi-gitlab"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}