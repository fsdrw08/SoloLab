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

data_dirs = "/mnt/data/v2rayA"

container = {
  network = {
    create      = true
    name        = "v2rayA"
    cidr_prefix = "172.16.1.0/24"
  }
  workload = {
    name        = "v2rayA"
    image       = "docker.io/mzz2017/v2raya:v2.2.5.8"
    local_image = "/mnt/data/offline/images/docker.io_mzz2017_v2raya_v2.2.5.8.tar"
    others = {
      # "network v2rayA address" = "172.16.1.10"
      "allow-host-networks" = ""
      "memory"              = "1024"

      "environment TZ value" = "Asia/Shanghai"

      "volume v2rayA_data source"      = "/mnt/data/v2rayA"
      "volume v2rayA_data destination" = "/etc/v2raya"
    }
  }
}

reverse_proxy = {
  web_frontend = {
    path = "load-balancing reverse-proxy service tcp443 rule 20"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockroach.day0.sololab"
      "set backend" = "cockroach_5443"
    }
  }
  web_backend = {
    path = "load-balancing reverse-proxy backend cockroach_5443"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.1.10"
      "server vyos port"    = "5443"
    }
  }
  sql_frontend = {
    path = "load-balancing reverse-proxy service tcp5432"
    configs = {
      "listen-address" = "192.168.255.1"
      "port"           = "5432"
      "mode"           = "tcp"
      "backend"        = "cockroach_5432"
    }
  }
  sql_backend = {
    path = "load-balancing reverse-proxy backend cockroach_5432"
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
