prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

reverse_proxy = {
  day0_backend = {
    path = "load-balancing haproxy backend day0"
    configs = {
      "mode"                      = "tcp"
      "server day0 address"       = "192.168.255.10"
      "server day0 port"          = "443"
      "server day0 send-proxy-v2" = ""
    }
  }
  day1_backend = {
    path = "load-balancing haproxy backend day1"
    configs = {
      "mode"                      = "tcp"
      "server day1 address"       = "192.168.255.20"
      "server day1 port"          = "443"
      "server day1 send-proxy-v2" = ""
    }
  }
  day0_frontend_zot = {
    path = "load-balancing haproxy service tcp443 rule 100"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "zot.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_etcd = {
    path = "load-balancing haproxy service tcp443 rule 110"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "etcd-0.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 120"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_cockpit = {
    path = "load-balancing haproxy service tcp443 rule 130"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_lldap = {
    path = "load-balancing haproxy service tcp443 rule 140"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "lldap.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_dex = {
    path = "load-balancing haproxy service tcp443 rule 145"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "dex.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_dufs = {
    path = "load-balancing haproxy service tcp443 rule 150"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "dufs.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_minio_api = {
    path = "load-balancing haproxy service tcp443 rule 160"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "minio-api.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_minio_console = {
    path = "load-balancing haproxy service tcp443 rule 165"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "minio-console.day0.sololab"
      "set backend" = "day0"
    }
  }
  # day0_frontend_sftpgo = {
  #   path = "load-balancing haproxy service tcp443 rule 160"
  #   configs = {
  #     "ssl"         = "req-ssl-sni"
  #     "domain-name" = "sftpgo.day0.sololab"
  #     "set backend" = "day0"
  #   }
  # }
  day0_frontend_whoami = {
    path = "load-balancing haproxy service tcp443 rule 170"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "whoami.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_consul = {
    path = "load-balancing haproxy service tcp443 rule 180"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "consul-client.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_podman_exporter = {
    path = "load-balancing haproxy service tcp443 rule 190"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus-podman-exporter.day0.sololab"
      "set backend" = "day0"
    }
  }
  day0_frontend_alloy = {
    path = "load-balancing haproxy service tcp443 rule 191"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "alloy.day0.sololab"
      "set backend" = "day0"
    }
  }
  day1_frontend_vault = {
    path = "load-balancing haproxy service tcp443 rule 200"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "vault.day1.sololab"
      "set backend" = "day1_vault"
    }
  }
  day1_backend_vault = {
    path = "load-balancing haproxy backend day1_vault"
    configs = {
      "mode"                       = "tcp"
      "server vault address"       = "192.168.255.20"
      "server vault port"          = "8200"
      "server vault send-proxy-v2" = ""
    }
  }
  # day1_frontend_vault = {
  #   path = "load-balancing haproxy service tcp443 rule 200"
  #   configs = {
  #     "ssl"         = "req-ssl-sni"
  #     "domain-name" = "vault.day1.sololab"
  #     "set backend" = "day1"
  #   }
  # }
  day1_frontend_consul = {
    path = "load-balancing haproxy service tcp443 rule 210"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "consul.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 220"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_nomad = {
    path = "load-balancing haproxy service tcp443 rule 230"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "nomad.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_grafana = {
    path = "load-balancing haproxy service tcp443 rule 240"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "grafana.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_loki = {
    path = "load-balancing haproxy service tcp443 rule 250"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "loki.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_prometheus = {
    path = "load-balancing haproxy service tcp443 rule 260"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_prometheus_blackbox_exporter = {
    path = "load-balancing haproxy service tcp443 rule 261"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus-blackbox-exporter.day1.sololab"
      "set backend" = "day1"
    }
  }
  day2_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 300"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day2.sololab"
      "set backend" = "day1"
    }
  }
}
