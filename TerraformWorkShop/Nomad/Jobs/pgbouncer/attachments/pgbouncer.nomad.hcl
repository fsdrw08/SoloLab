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
    operator  = "!="
    value     = "day1"
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
        provider = "consul"
        name     = "pgbouncer-${attr.unique.hostname}"

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
      }

      user = "996:996"

      driver = "podman"
      config {
        image = "zot.day0.sololab/cloudnative-pg/pgbouncer:1.25.1"

        hostname = "${attr.unique.hostname}"

        volumes = [
          "local/pgbouncer.ini:/etc/pgbouncer/pgbouncer.ini",
          "secrets/userlist.txt:/etc/pgbouncer/userlist.txt",
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
        data        = var.pgbouncer_config
        destination = "local/pgbouncer.ini"
      }

      template {
        data          = <<-EOF
          "pgbounder" \"{{ "P@ssw0rd" | md5sum }}\"
          {{- range secrets "kvv2_pgsql/metadata/" -}}
          {{- with secret (printf "kvv2_pgsql/data/%s" .) -}}
          "{{ .Data.data.username }}" "{{ .Data.data.password | md5sum }}"
          {{- end -}}
          {{- end -}}
        EOF
        destination   = "secrets/userlist.txt"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
      vault {}
    }
  }
}