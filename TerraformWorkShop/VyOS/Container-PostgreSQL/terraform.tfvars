vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

runas = {
  uid         = 26
  gid         = 100
  take_charge = false
}

data_dirs = "/mnt/data/postgresql"

container = {
  network = {
    create      = true
    name        = "postgresql"
    cidr_prefix = "172.16.1.0/24"
  }
  # https://quay.io/repository/fedora/postgresql-16
  workload = {
    name        = "postgresql"
    image       = "quay.io/fedora/postgresql-16:latest"
    local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
    others = {
      "network postgresql address" = "172.16.1.10"
      "memory"                     = "1024"

      "environment TZ value"                        = "Asia/Shanghai"
      "environment POSTGRESQL_USER value"           = "terraform"
      "environment POSTGRESQL_PASSWORD value"       = "terraform"
      "environment POSTGRESQL_DATABASE value"       = "tfstate"
      "environment POSTGRESQL_ADMIN_PASSWORD value" = "P@ssw0rd"

      "volume postgresql_data source"      = "/mnt/data/postgresql"
      "volume postgresql_data destination" = "/var/lib/pgsql/data"

    }
  }
}

reverse_proxy = {
  sql_frontend = {
    path = "load-balancing haproxy service tcp5432"
    configs = {
      "listen-address" = "192.168.255.1"
      "port"           = "5432"
      "mode"           = "tcp"
      "backend"        = "postgresql_5432"
    }
  }
  sql_backend = {
    path = "load-balancing haproxy backend postgresql_5432"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.1.10"
      "server vyos port"    = "5432"
    }
  }
}

dns_records = [
  {
    host = "postgresql.day0.sololab"
    ip   = "192.168.255.1"
  },
  # {
  #   host = "adminer.day0.sololab"
  #   ip   = "192.168.255.1"
  # }
]
