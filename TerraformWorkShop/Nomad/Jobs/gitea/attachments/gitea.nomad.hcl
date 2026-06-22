variable "config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "gitea" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "gitea" {
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
        URL=postgres://{{with secret "kvv2_others/data/app-gitea"}}{{.Data.data.pgsql_user_name}}{{end}}:{{with secret "kvv2_others/data/app-gitea"}}{{.Data.data.pgsql_user_password}}{{end}}@day3.pgbouncer.service.consul:6432/gitea?sslmode=require
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}
      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 100
        # Specifies the memory required in MB
        memory = 50
      }
    }
    task "wait4x-redis" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
        args = [
          "redis",
          "redis://gitea:gitea@day3.redis.service.consul:6379/0",
        ]
      }
      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 100
        # Specifies the memory required in MB
        memory = 50
      }
    }
    task "wait4x-minio" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "podman"
      config {
        image = "zot.day1.sololab/wait4x/wait4x:3.6.0"
        args = [
          "http",
          "https://minio-api.day1.sololab/minio/health/live",
          # https://github.com/wait4x/wait4x/pull/35
          "--insecure-skip-tls-verify",
          "--expect-status-code",
          "200",
        ]
      }
      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 100
        # Specifies the memory required in MB
        memory = 50
      }
    }

    network {
      port "gitea-ssh" {
        static = 2222
        to     = 22
      }
    }

    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "gitea" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "gitea"
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
          "traefik.http.routers.gitea-redirect.entryPoints=web",
          "traefik.http.routers.gitea-redirect.rule=Host(`gitea.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitea-redirect.middlewares=toHttps@file",

          "traefik.http.routers.gitea.entryPoints=webSecure",
          "traefik.http.routers.gitea.rule=Host(`gitea.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.gitea.tls.certresolver=internal",

          "traefik.http.services.gitea.loadbalancer.server.scheme=https",
          "traefik.http.services.gitea.loadbalancer.server.port=443",
          "traefik.http.services.gitea.loadBalancer.serversTransport=consul-service@file",
        ]

        # meta {
        #   prom_blackbox_scheme            = "https"
        #   prom_blackbox_address           = "gitea.service.consul"
        #   prom_blackbox_health_check_path = "/health"

        #   prom_target_scheme       = "https"
        #   prom_target_address      = "gitea.service.consul"
        #   prom_target_metrics_path = "metrics"
        # }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://github.com/go-gitea/gitea/blob/v1.26.4/Dockerfile.rootless
        image = "zot.day1.sololab/gitea/gitea:1.26.4-rootless"
        labels = {
          "traefik.enable"                                  = "true"
          "traefik.http.routers.gitea-redirect.entrypoints" = "web"
          "traefik.http.routers.gitea-redirect.rule"        = "(Host(`gitea.day4.sololab`)||Host(`gitea.service.consul`))"
          "traefik.http.routers.gitea-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.gitea-redirect.service"     = "gitea"

          "traefik.http.routers.gitea.entryPoints" = "webSecure"
          "traefik.http.routers.gitea.rule"        = "(Host(`gitea.day4.sololab`)||Host(`gitea.service.consul`))"
          "traefik.http.routers.gitea.tls"         = "true"
          "traefik.http.routers.gitea.service"     = "gitea"

          "traefik.http.services.gitea.loadbalancer.server.port" = "3000"
        }
        ports = [
          "gitea-ssh",
        ]
        sysctl = {
          "net.ipv4.ip_unprivileged_port_start" = "22"
        }
        volumes = [
          # Customization files should be placed in /var/lib/gitea/custom directory
          # https://docs.gitea.com/1.26/installation/install-with-docker-rootless#customization
          # https://docs.gitea.com/1.26/administration/customizing-gitea#customizing-the-git-configuration
          # https://docs.gitea.com/installation/install-with-docker-rootless#customization
          # https://docs.gitea.com/administration/customizing-gitea#customizing-the-git-configuration
          "local/app.ini:/etc/gitea/app.ini",
        ]

      }

      env {
        GITEA__security__INSTALL_LOCK = "true"
        SSL_CERT_FILE                 = "/secrets/sololab.crt"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 600
        # Specifies the memory required in MB
        memory = 800
      }

      template {
        change_mode = "noop"
        data        = var.config
        destination = "local/app.ini"
        uid         = 1000
        gid         = 1000
      }
      template {
        change_mode = "noop"
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/sololab.crt"
      }
      vault {}

      volume_mount {
        volume        = "gitea-data"
        destination   = "/var/lib/gitea"
        selinux_label = "Z"
      }
    }
    volume "gitea-data" {
      type            = "csi"
      source          = "csi-gitea-data"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}