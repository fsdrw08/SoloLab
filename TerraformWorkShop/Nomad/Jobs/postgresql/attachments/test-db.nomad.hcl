# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "test-db" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "test-db" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "test-db" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "test-db-${attr.unique.hostname}"

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
          "behind_pgbouncer",
          "log",
          "metrics-exposing-general",
        ]

        meta {
          # https://developer.hashicorp.com/nomad/docs/reference/runtime-environment-settings#job-related-variables
          # meta data to render pgbouncer config with consul template
          dbName   = "test"
          dbConfig = "host=${NOMAD_TASK_NAME}-${NOMAD_ALLOC_ID} dbname=test auth_user=pgbouncer"
          # meta data to render pgweb config with consul template
          dbUser        = "test"
          pgBouncerHost = "pgbouncer-${node.unique.name}.service.consul"
          # meta data for Prometheus consul_sd_config:
          # this postgresql server hosting behind pgbouncer, so we need to tell 
          # prometheus to scrap metrics from postgres exporter with multi target pattern:
          # https://prometheus-postgres-exporter.service.consul/probe?auth_module=postgres_exporter&target=postgresql-day2.service.consul%3A5432%2Ftest
          prom_target_scheme                         = "https"
          prom_target_address                        = "prometheus-postgres-exporter.service.consul"
          prom_target_metrics_path                   = "probe"
          prom_target_metrics_path_param_auth_module = "postgres_exporter"
          prom_target_metrics_path_param_target      = "pgbouncer-${attr.unique.hostname}.service.consul:6432/test"
        }
      }

      user = "26:26"

      driver = "podman"
      config {
        image = "zot.day0.sololab/fedora/postgresql-16:20260203"
        volumes = [
          "local/postgresql_hba.conf:/opt/app-root/src/postgresql-cfg/postgresql_hba.conf",
          "local/init-db.sh:/opt/app-root/src/postgresql-start/init-db.sh",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        POSTGRESQL_DATABASE        = "test"
        POSTGRESQL_LOG_DESTINATION = "/dev/stderr"
      }

      template {
        # https://github.com/sclorg/postgresql-container/blob/b2645eaceed24be95676cfeb2fe24df3c5e45468/16/root/usr/share/container-scripts/postgresql/common.sh#L212
        data = <<-EOH
        hba_file = '/local/pg_hba.conf'
        EOH

        destination = "local/postgresql_hba.conf"
      }

      template {
        data          = <<-EOH
        local  all          all                              trust
        host   all          all                127.0.0.1/32  trust
        host   all          all                ::1/128       trust
        local  replication  all                      trust
        host   replication  all                127.0.0.1/32  trust
        host   replication  all                ::1/128       trust

        host  all           pgbouncer          10.88.0.0/16  trust
        host  all           postgres_exporter  10.88.0.0/16  trust
        host  all           {{with secret "kvv2_pgsql/data/test"}}{{.Data.data.user_name}}{{end}}       all           scram-sha-256
        EOH
        destination   = "local/pg_hba.conf"
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
        
        DROP ROLE IF EXISTS postgres_exporter;
        CREATE ROLE postgres_exporter WITH LOGIN PASSWORD '{{with secret "kvv2_pgsql/data/postgres_exporter"}}{{.Data.data.user_password}}{{end}}';
        GRANT pg_monitor TO postgres_exporter;
        ---GRANT CONNECT ON DATABASE postgres TO postgres_exporter;
        ---GRANT CONNECT ON DATABASE test TO postgres_exporter;

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
        volume        = "test-db"
        destination   = "/var/lib/pgsql/data"
        selinux_label = "Z"
      }
    }
    volume "test-db" {
      type            = "host"
      source          = "test-db"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}