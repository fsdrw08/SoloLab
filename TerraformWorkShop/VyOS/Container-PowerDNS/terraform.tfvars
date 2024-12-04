vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

vyos_conn = {
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

runas = {
  uid         = 953
  gid         = 953
  take_charge = false
}

data_dirs = "/mnt/data/powerdns"

container = {
  network = {
    create      = true
    name        = "powerdns"
    cidr_prefix = "172.16.2.0/24"
  }
  # https://hub.docker.com/r/powerdns/pdns-auth-49/tags
  workload = {
    name      = "powerdns"
    image     = "zot.day0.sololab/powerdns/pdns-auth-49:4.9.2"
    pull_flag = "--tls-verify=false"

    # local_image = "/mnt/data/offline/images/quay.io_fedora_postgresql-16_latest.tar"
    local_image = ""
    others = {
      "network postgresql address" = "172.16.2.10"
      "memory"                     = "1024"

      "environment TZ value"                = "Asia/Shanghai"
      "environment PDNS_AUTH_API_KEY value" = "powerdns"
      "environment PNDS_DNSUPDATE value"    = "yes"

      # https://github.com/PowerDNS/pdns/blob/master/Dockerfile-auth
      # https://github.com/PowerDNS/pdns/blob/master/dockerdata/pdns.conf
      # https://doc.powerdns.com/authoritative/settings.html#include-dir
      "volume pdns_conf source"      = "/etc/powerdns/pdns.d"
      "volume pdns_conf destination" = "/etc/powerdns/pdns.d"

      "volume pdns_data source"      = "/mnt/data/powerdns"
      "volume pdns_data destination" = "/var/lib/powerdns"

    }
  }
}

reverse_proxy = {
  api_frontend = {
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
]
