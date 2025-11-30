prov_system = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

service_monitoring = {
  "node_exporter" = {
    path = "service monitoring prometheus node-exporter"
    configs = {
      "listen-address"      = "127.0.0.1"
      "port"                = "9100"
      "collectors textfile" = ""
    }
  }
  # "telegraf_loki" = {
  #   path = "service monitoring telegraf loki"
  #   configs = {
  #     "port" = "443"
  #     "url"  = "https://loki.day1.sololab"
  #   }
  # }
}

reverse_proxy = {
  l4_frontend = {
    path = "load-balancing haproxy service tcp443 rule 90"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus-node-exporter.vyos.sololab"
      "set backend" = "vyos_node_exporter_ssl"
    }
  }
  l4_backend = {
    path = "load-balancing haproxy backend vyos_node_exporter_ssl"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "127.0.0.1"
      "server vyos port"    = "19100"
    }
  }
  l7_frontend = {
    path = "load-balancing haproxy service vyos_node_exporter_ssl"
    configs = {
      "listen-address 127.0.0.1" = ""
      "port"                     = "19100"
      "mode"                     = "tcp"
      "backend"                  = "vyos_node_exporter"
      "ssl certificate"          = "vyos"
    }
  }
  l7_backend = {
    path = "load-balancing haproxy backend vyos_node_exporter"
    configs = {
      "mode"                = "http"
      "server vyos address" = "127.0.0.1"
      "server vyos port"    = "9100"
    }
  }
}
