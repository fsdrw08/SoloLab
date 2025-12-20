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
          dbConfig = "host=${NOMAD_TASK_NAME}-${NOMAD_ALLOC_ID} dbname=test auth_user=pgbouncer"
        }
      }

      user = "26:26"

      driver = "podman"
      config {
        image = "zot.day0.sololab/fedora/postgresql-16:20251217"
        volumes = [
          "local/postgresql_hba.conf:/opt/app-root/src/postgresql-cfg/postgresql_hba.conf",
          "local/init-db.sh:/opt/app-root/src/postgresql-start/init-db.sh",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        POSTGRESQL_DATABASE = "test"
      }

      template {
        # https://github.com/sclorg/postgresql-container/blob/b2645eaceed24be95676cfeb2fe24df3c5e45468/16/root/usr/share/container-scripts/postgresql/common.sh#L212
        data = <<-EOH
        hba_file = '/local/pg_hba.conf'
        EOH

        destination = "local/postgresql_hba.conf"
      }

      template {
        data = <<-EOH
        local  all          all                      trust
        host   all          all        127.0.0.1/32  trust
        host   all          all        ::1/128       trust
        local  replication  all                      trust
        host   replication  all        127.0.0.1/32  trust
        host   replication  all        ::1/128       trust

        host  all           pgbouncer  10.88.0.0/16  trust
        host  all           test       all           scram-sha-256
        EOH
        destination = "local/pg_hba.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        # https://www.enterprisedb.com/postgres-tutorials/pgbouncer-authquery-and-authuser-pro-tips
        # https://readmedium.com/unlocking-advanced-authentication-in-pgbouncer-a-guide-to-auth-query-and-auth-user-configuration-6189e0fd0562
        # auth function need to create in target database
        data = <<-EOH
        #!/bin/bash
        set -e
        psql -v ON_ERROR_STOP=1 <<-EOSQL
        DROP ROLE IF EXISTS pgbouncer;
        CREATE ROLE pgbouncer WITH LOGIN PASSWORD 'pgbouncer';
        \\c test;
        CREATE OR REPLACE FUNCTION user_search(uname TEXT) RETURNS TABLE (usename name, passwd text) as
        \$\$
          SELECT usename, passwd FROM pg_shadow WHERE usename=\$1;
        \$\$
        LANGUAGE sql SECURITY DEFINER;
        EOSQL
        EOH

        destination = "local/init-db.sh"
        change_mode = "restart"
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