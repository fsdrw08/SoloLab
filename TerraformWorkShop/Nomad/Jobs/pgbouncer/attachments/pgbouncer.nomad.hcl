variable "pgbouncer_config" {
  type = string
}

# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "pgbouncer" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "pgbouncer" {
    network {
      port "pgbouncer" {
        static = 6432
      }
    }
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "pgbouncer" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider     = "consul"
        name         = "pgbouncer-${attr.unique.hostname}"
        address_mode = "host"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          type           = "tcp"
          port           = "pgbouncer"
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",
        ]

        # meta {
        #   # https://developer.hashicorp.com/nomad/docs/reference/runtime-environment-settings#job-related-variables
        #   "NOMAD_JOB_NAME" = "${NOMAD_JOB_NAME}"
        #   "NOMAD_ALLOC_ID" = "${NOMAD_ALLOC_ID}"
        # }
      }

      user = "996:996"

      driver = "podman"
      config {
        # https://github.com/cloudnative-pg/pgbouncer-containers/blob/main/entrypoint.sh
        image = "zot.day0.sololab/cloudnative-pg/pgbouncer:1.25.1"

        ports = [
          "pgbouncer",
        ]

        entrypoint = "/usr/bin/pgbouncer"
        command    = "/local/pgbouncer.ini"

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
        data          = var.pgbouncer_config
        destination   = "local/pgbouncer.ini"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        # https://github.com/hashicorp/consul-template/blob/main/docs/templating-language.md#secrets
        # https://www.pgbouncer.org/config.html#authentication-file-format
        # https://www.percona.com/blog/configuring-pgbouncer-auth_type-with-trust-and-hba-examples-and-known-issues/#:~:text=%3D6s)-,auth_query%20method,-If%20you%20do
        # PostgreSQL MD5-hashed password format:
        # "md5" + md5(password + username)
        # So user admin with password 1234 will have MD5-hashed password md545f2603610af569b6155c45067268c6b.
        data          = <<-EOF
          "pgbounder" "md5{{ "pgbounderpgbounder" | md5sum }}"
        EOF
        destination   = "secrets/userlist.txt"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      # template {
      #   # https://www.percona.com/blog/configuring-pgbouncer-auth_type-with-trust-and-hba-examples-and-known-issues/#:~:text=%3D6s)-,auth_query%20method,-If%20you%20do
      #   data = <<-EOH
      #   host all pgbounder all md5
      #   host all all all scram-sha-256
      #   EOH

      #   destination = "local/pg_hba.conf"
      #   change_mode   = "signal"
      #   change_signal = "SIGHUP"
      # }

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
    }
  }
}
