# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "artifact-keeper" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day4"
  }

  group "artifact-keeper-backend" {
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
      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 100
        # Specifies the memory required in MB
        memory = 50
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
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "artifact-keeper-backend" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "artifact-keeper-backend"
        # need to set address_mode to "host" to make this service resolve to host ip address in consul
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
        #   traefik.day2 -[http route: decrypt(meilisearch.day3.sololab) & re-encrypt(server transport(meilisearch-day3.service.consul)) & ]-> 
        #   traefik.day4 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          "traefik.enable=true",
          "traefik.http.routers.artifact-keeper-backend-redirect.entryPoints=web",
          "traefik.http.routers.artifact-keeper-backend-redirect.rule=Host(`artifact-keeper.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.artifact-keeper-backend-redirect.middlewares=toHttps@file",

          "traefik.http.routers.artifact-keeper-backend.entryPoints=webSecure",
          "traefik.http.routers.artifact-keeper-backend.rule=Host(`artifact-keeper.${attr.unique.hostname}.sololab`)",
          "traefik.http.routers.artifact-keeper-backend.tls.certresolver=internal",

          "traefik.http.services.artifact-keeper-backend.loadbalancer.server.scheme=https",
          "traefik.http.services.artifact-keeper-backend.loadbalancer.server.port=443",
          "traefik.http.services.artifact-keeper-backend.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "artifact-keeper-backend.service.consul"
          prom_blackbox_health_check_path = "/health"

          # prom_target_scheme       = "https"
          # prom_target_address      = "artifact-keeper.service.consul"
          # prom_target_metrics_path = "metrics"
        }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://github.com/artifact-keeper/artifact-keeper/blob/v1.7.0/docker/Dockerfile.backend
        image = "zot.day1.sololab/artifact-keeper/artifact-keeper-backend:1.7.0"
        labels = {
          "traefik.enable"                                                    = "true"
          "traefik.http.routers.artifact-keeper-backend-redirect.entrypoints" = "web"
          "traefik.http.routers.artifact-keeper-backend-redirect.rule"        = "(Host(`artifact-keeper.day4.sololab`)||Host(`artifact-keeper-backend.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/health`) || PathPrefix(`/livez`) || PathPrefix(`/readyz`) || PathPrefix(`/metrics`))"
          "traefik.http.routers.artifact-keeper-backend-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.artifact-keeper-backend-redirect.service"     = "artifact-keeper-backend"

          "traefik.http.routers.artifact-keeper-backend.entryPoints" = "webSecure"
          "traefik.http.routers.artifact-keeper-backend.rule"        = "(Host(`artifact-keeper.day4.sololab`)||Host(`artifact-keeper-backend.service.consul`)) && (PathPrefix(`/api`) || PathPrefix(`/health`) || PathPrefix(`/livez`) || PathPrefix(`/readyz`) || PathPrefix(`/metrics`))"
          "traefik.http.routers.artifact-keeper-backend.tls"         = "true"
          "traefik.http.routers.artifact-keeper-backend.service"     = "artifact-keeper-backend"

          "traefik.http.services.artifact-keeper-backend.loadbalancer.server.port" = "8080"
        }
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 600
        # Specifies the memory required in MB
        memory = 600
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/template
      template {
        change_mode = "noop"
        data        = <<-EOF
          {{ with secret "kvv2_certs/data/sololab_root" }}{{ .Data.data.ca }}{{ end }}
        EOF
        destination = "secrets/sololab.crt"
      }
      template {
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        # https://github.com/artifact-keeper/artifact-keeper/blob/v1.7.0/.env.example
        DATABASE_URL=postgresql://{{with secret "kvv2_others/data/app-artifact-keeper"}}{{.Data.data.pgsql_user_name}}{{end}}:{{with secret "kvv2_others/data/app-artifact-keeper"}}{{.Data.data.pgsql_user_password}}{{end}}@pgbouncer.service.consul:6432/artifact-keeper?sslmode=require
        
        # S3 config
        STORAGE_BACKEND=s3
        S3_BUCKET=artifact-keeper
        S3_REGION=us-east-1
        S3_ENDPOINT=https://minio-api.day1.sololab
        S3_ACCESS_KEY_ID={{with secret "kvv2_minio/data/artifact-keeper"}}{{.Data.data.access_key}}{{end}}
        S3_SECRET_ACCESS_KEY={{with secret "kvv2_minio/data/artifact-keeper"}}{{.Data.data.secret_key}}{{end}}
        # https://github.com/artifact-keeper/artifact-keeper/blob/v1.7.0/.env.example#L135
        S3_CA_CERT_PATH=/secrets/sololab.crt

        # Others
        PLUGINS_DIR=/data/plugins
        JWT_SECRET={{with secret "kvv2_others/data/app-artifact-keeper"}}{{.Data.data.jwt_secret}}{{end}}
        ADMIN_PASSWORD={{with secret "kvv2_others/data/app-artifact-keeper"}}{{.Data.data.admin_password}}{{end}}
        RUST_LOG=info,artifact_keeper=debug
        ENVIRONMENT=development
        # https://github.com/artifact-keeper/artifact-keeper/issues/2529
        CUSTOM_CA_CERT_PATH=/secrets/sololab.crt
        SSO_ALLOW_PRIVATE_IPS=true

        # OIDC
        # https://github.com/artifact-keeper/artifact-keeper/issues/2808
        # OIDC_NAME have to set to string "default"
        OIDC_NAME=default
        OIDC_ISSUER={{with secret "kvv2_vault/data/oidc-provider_sololab"}}{{.Data.data.issuer}}{{end}}
        OIDC_CLIENT_ID={{with secret "kvv2_vault/data/oidc-client_artifact-keeper"}}{{.Data.data.client_id}}{{end}}
        OIDC_CLIENT_SECRET={{with secret "kvv2_vault/data/oidc-client_artifact-keeper"}}{{.Data.data.client_secret}}{{end}}
        OIDC_REDIRECT_URI=https://artifact-keeper.day4.sololab/api/v1/auth/sso/oidc/callback
        OIDC_SCOPES=openid profile email groups
        OIDC_USERNAME_CLAIM=preferred_username
        OIDC_EMAIL_CLAIM=email
        OIDC_GROUPS_CLAIM=groups
        OIDC_DEFAULT_ROLE=user
        OIDC_ADMIN_GROUP=app-artifact-keeper-admin
        OIDC_GROUP_ROLE_MAP=app-artifact-keeper-admin:admin;app-artifact-keeper-user:user;app-artifact-keeper-viewer:viewer
        OIDC_MAP_GROUPS_TO_GROUPS=false
        OIDC_AUTO_CREATE_USERS=true
        OIDC_PKCE_ENABLED=true
        EOH
        # https://developer.hashicorp.com/nomad/docs/job-specification/template#environment-variables
        destination = "secrets/file.env"
        env         = true
      }
      vault {}

      volume_mount {
        volume        = "artifact-keeper-plugins-data"
        destination   = "/data/plugins"
        selinux_label = "Z"
      }
    }
    # https://developer.hashicorp.com/nomad/docs/job-specification/volume
    volume "artifact-keeper-plugins-data" {
      type            = "host"
      source          = "hvol-artifact-keeper-plugins"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
  group "artifact-keeper-web" {
    # https://developer.hashicorp.com/nomad/docs/job-specification/task
    task "artifact-keeper-web" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "artifact-keeper-web"
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
        #   traefik.day4 -[http route: decrypt(*.service.consul)]-> app
        tags = [
          "metrics-exposing-blackbox",
          "metrics-exposing-general",
          "log",

          # "traefik.enable=true",
          # "traefik.http.routers.artifact-keeper-web-redirect.entryPoints=web",
          # "traefik.http.routers.artifact-keeper-web-redirect.rule=Host(`artifact-keeper.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.artifact-keeper-web-redirect.middlewares=toHttps@file",

          # "traefik.http.routers.artifact-keeper-web.entryPoints=webSecure",
          # "traefik.http.routers.artifact-keeper-web.rule=Host(`artifact-keeper.${attr.unique.hostname}.sololab`)",
          # "traefik.http.routers.artifact-keeper-web.tls.certresolver=internal",

          # "traefik.http.services.artifact-keeper-web.loadbalancer.server.scheme=https",
          # "traefik.http.services.artifact-keeper-web.loadbalancer.server.port=443",
          # "traefik.http.services.artifact-keeper-web.loadBalancer.serversTransport=consul-service@file",
        ]

        meta {
          prom_blackbox_scheme            = "https"
          prom_blackbox_address           = "artifact-keeper-web.service.consul"
          prom_blackbox_health_check_path = "/health"

          # prom_target_scheme       = "https"
          # prom_target_address      = "artifact-keeper.service.consul"
          # prom_target_metrics_path = "metrics"
        }
      }

      # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
      driver = "podman"
      config {
        # https://github.com/artifact-keeper/artifact-keeper-web/blob/v1.8.0/Dockerfile
        image = "zot.day1.sololab/artifact-keeper/artifact-keeper-web:1.8.0"
        labels = {
          "traefik.enable"                                                = "true"
          "traefik.http.routers.artifact-keeper-web-redirect.entrypoints" = "web"
          "traefik.http.routers.artifact-keeper-web-redirect.rule"        = "Host(`artifact-keeper.day4.sololab`)||Host(`artifact-keeper-web.service.consul`)"
          "traefik.http.routers.artifact-keeper-web-redirect.middlewares" = "toHttps@file"
          "traefik.http.routers.artifact-keeper-web-redirect.service"     = "artifact-keeper-web"
          "traefik.http.routers.artifact-keeper-web-redirect.priority"    = "1"

          "traefik.http.routers.artifact-keeper-web.entryPoints" = "webSecure"
          "traefik.http.routers.artifact-keeper-web.rule"        = "Host(`artifact-keeper.day4.sololab`)||Host(`artifact-keeper-web.service.consul`)"
          "traefik.http.routers.artifact-keeper-web.tls"         = "true"
          "traefik.http.routers.artifact-keeper-web.priority"    = "2"
          "traefik.http.routers.artifact-keeper-web.service"     = "artifact-keeper-web"

          "traefik.http.services.artifact-keeper-web.loadbalancer.server.port" = "3000"
        }
      }
      env {
        BACKEND_URL      = "https://artifact-keeper-backend.service.consul"
        AK_ENFORCE_HTTPS = "true"
      }

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 300
        # Specifies the memory required in MB
        memory = 300
      }
    }
    # https://developer.hashicorp.com/nomad/docs/job-specification/volume
    volume "artifact-keeper-plugins-data" {
      type            = "host"
      source          = "hvol-artifact-keeper-plugins"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}