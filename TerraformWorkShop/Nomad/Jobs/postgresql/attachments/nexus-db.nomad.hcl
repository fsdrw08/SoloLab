# https://developer.hashicorp.com/nomad/docs/job-specification/job
# https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-grafana
job "nexus-db" {
  datacenters = ["dc1"]
  region      = "global"
  #   https://developer.hashicorp.com/nomad/docs/concepts/scheduling/schedulers
  type = "service"

  constraint {
    attribute = "${attr.unique.hostname}"
    operator  = "="
    value     = "day2"
  }

  group "nexus-db" {
    # https://developer.hashicorp.com/nomad/plugins/drivers/podman#task-configuration
    task "nexus-db" {
      # https://developer.hashicorp.com/nomad/docs/job-specification/service
      service {
        provider = "consul"
        name     = "nexus-db-${attr.unique.hostname}"

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
          dbName   = "nexus"
          dbConfig = "host=${NOMAD_TASK_NAME}-${NOMAD_ALLOC_ID} dbname=nexus auth_user=pgbouncer"
          # meta data to render pgweb config with consul template
          dbUser        = "nexus"
          pgBouncerHost = "pgbouncer-${node.unique.name}.service.consul"
          # meta data for Prometheus consul_sd_config:
          # this postgresql server hosting behind pgbouncer, so we need to tell 
          # prometheus to scrap metrics from postgres exporter with multi target pattern:
          # https://prometheus-postgres-exporter.service.consul/probe?auth_module=postgres_exporter&target=postgresql-day2.service.consul%3A5432%2Fnexus3
          prom_target_scheme                         = "https"
          prom_target_address                        = "prometheus-postgres-exporter.service.consul"
          prom_target_metrics_path                   = "probe"
          prom_target_metrics_path_param_auth_module = "postgres_exporter"
          prom_target_metrics_path_param_target      = "pgbouncer-${attr.unique.hostname}.service.consul:6432/nexus"
        }
      }

      user = "26:26"

      driver = "podman"
      config {
        image = "zot.day0.sololab/fedora/postgresql-18:20260218"
        volumes = [
          "local/postgresql_hba.conf:/opt/app-root/src/postgresql-cfg/postgresql_hba.conf",
          # https://github.com/sclorg/postgresql-container/blob/master/18/root/usr/share/container-scripts/postgresql/README.md#postgresql-init
          # postgresql-init/: This directory should contain shell scripts (*.sh) that are sourced when the database is freshly initialized (after a successful initdb run, which makes the data directory non-empty).
          # At the time of sourcing these scripts, the local PostgreSQL server is running. For re-deployment scenarios with a persistent data directory, the scripts are not sourced (no-op).
          # "local/init-schema.sh:/opt/app-root/src/postgresql-start/init-schema.sh",

          # postgresql-start/: This directory has the same semantics as postgresql-init/, except that these scripts are always sourced (after postgresql-init/ scripts, if they exist).
          "local/init-db.sh:/opt/app-root/src/postgresql-start/init-db.sh",
          "local/init-schema.sh:/opt/app-root/src/postgresql-start/init-schema.sh",
        ]
      }

      # https://developer.hashicorp.com/nomad/docs/job-specification/env
      env {
        POSTGRESQL_DATABASE        = "nexus"
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
        host  all           {{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}}       all           scram-sha-256
        EOH
        destination   = "local/pg_hba.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        # https://github.com/sclorg/postgresql-container/blob/master/18/root/usr/share/container-scripts/postgresql/README.md#postgresql-init
        # https://help.sonatype.com/en/install-nexus-repository-with-a-postgresql-database.html#create-a-postgresql-database
        data        = <<-EOH
        #!/bin/bash
        set -e
        psql -v ON_ERROR_STOP=1 <<-EOSQL
        \\c nexus;
        CREATE SCHEMA IF NOT EXISTS nexus;
        GRANT ALL PRIVILEGES ON DATABASE nexus TO {{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}};
        GRANT ALL PRIVILEGES ON SCHEMA nexus TO {{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}};
        CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA nexus;
        EOSQL
        EOH
        destination = "local/init-schema.sh"
        change_mode = "restart"
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
        ---GRANT CONNECT ON DATABASE nexus TO postgres_exporter;

        \\c nexus;
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
        POSTGRESQL_USER={{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_name}}{{end}}
        POSTGRESQL_PASSWORD={{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.user_password}}{{end}}
        POSTGRESQL_ADMIN_PASSWORD={{with secret "kvv2_pgsql/data/nexus"}}{{.Data.data.admin_password}}{{end}}
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
        volume        = "nexus-db"
        destination   = "/var/lib/pgsql/data"
        selinux_label = "Z"
      }
    }
    volume "nexus-db" {
      type            = "host"
      source          = "nexus-db"
      read_only       = false
      attachment_mode = "file-system"
      access_mode     = "single-node-writer"
    }
  }
}