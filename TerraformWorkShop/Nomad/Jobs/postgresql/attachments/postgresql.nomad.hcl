# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "postgresql" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "postgresql" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "postgresql" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "postgresql-${attr.unique.hostname}"

        # https://developer.hashicorp.com/nomad/docs/job-specification/check#driver
        check {
          address_mode   = "driver"
          type           = "tcp"
          port           = 5432
          interval       = "180s"
          timeout        = "2s"
          initial_status = "passing"
        }

        tags = [
          "log",
          "behind_pgbouncer",
        ]

        meta {
          # https://developer.hashicorp.com/nomad/docs/reference/runtime-environment-settings#job-related-variables
          dbName   = "test"
          dbConfig = "host=${NOMAD_TASK_NAME}-${NOMAD_ALLOC_ID} dbname=test"
        }
      }

      user = "26:26"

      driver = "podman"
      config {
        image = "zot.day0.sololab/fedora/postgresql-16:20251203"
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        POSTGRESQL_DATABASE = "test"
      }

      template {
        data = <<-EOH
        # Lines starting with a # are ignored

        # Empty lines are also ignored
        POSTGRESQL_USER={{with secret "kvv2_pgsql/data/test"}}{{.Data.data.user_name}}{{end}}
        POSTGRESQL_PASSWORD={{with secret "kvv2_pgsql/data/test"}}{{.Data.data.user_password}}{{end}}
        POSTGRESQL_ADMIN_PASSWORD={{with secret "kvv2_pgsql/data/test"}}{{.Data.data.admin_password}}{{end}}
        EOH

        destination = "secrets/file.env"
        env         = true
      }
      vault {}

      resources {
        # Specifies the CPU required to run this task in MHz
        cpu = 200
        # Specifies the memory required in MB
        memory = 128
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/volume_mount
      volume_mount {
        volume        = "test"
        destination   = "/var/lib/pgsql/data"
        selinux_label = "Z"
      }
    }
    volume "test" {
      type            = "host"
      source          = "test"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}