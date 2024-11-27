vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

runas = {
  uid         = 0
  gid         = 0
  take_charge = false
}

data_dirs = "/mnt/data/cockroach"

container = {
  network = {
    create      = true
    name        = "cockroach"
    cidr_prefix = "172.16.2.0/24"
    address     = "172.16.2.10"
  }
  workload = {
    name = "cockroach"
    # image       = "docker.io/cockroachdb/cockroach:v23.2.5"
    # local_image = "/mnt/data/offline/images/docker.io_cockroachdb_cockroach_v23.2.5.tar"
    image       = "docker.io/cockroachdb/cockroach:latest-v24.2" # hub.geekery.cn/cockroachdb/cockroach:latest-v24.2
    local_image = "/mnt/data/offline/images/docker.io_cockroachdb_cockroach_latest-v24.2.tar"
    others = {
      "network cockroach address" = "172.16.2.10"
      "memory"                    = "1024"

      "environment TZ value" = "Asia/Shanghai"

      "volume cockroach_cert source"      = "/etc/cockroach/certs"
      "volume cockroach_cert destination" = "/certs"
      "volume cockroach_cert mode"        = "ro"
      "volume cockroach_data source"      = "/mnt/data/cockroach"
      "volume cockroach_data destination" = "/cockroach/cockroach-data"

      "arguments" = "start-single-node --sql-addr=:5432 --http-addr=:5443 --certs-dir=/certs --accept-sql-without-tls"
    }
  }
}

reverse_proxy = {
  web_frontend = {
    # path = "load-balancing reverse-proxy service tcp443 rule 20" # vyos 1.4
    path = "load-balancing haproxy service tcp443 rule 20" # vyos 1.5
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockroach.day0.sololab"
      "set backend" = "cockroach_5443"
    }
  }
  web_backend = {
    path = "load-balancing haproxy backend cockroach_5443"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.2.10"
      "server vyos port"    = "5443"
    }
  }
  sql_frontend = {
    path = "load-balancing haproxy service tcp5432"
    configs = {
      "listen-address" = "192.168.255.1"
      "port"           = "5432"
      "mode"           = "tcp"
      "backend"        = "cockroach_5432"
    }
  }
  sql_backend = {
    path = "load-balancing haproxy backend cockroach_5432"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.2.10"
      "server vyos port"    = "5432"
    }
  }
}

dns_record = {
  host = "cockroach.day0.sololab"
  ip   = "192.168.255.1"
}
