prov_vyos = {
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

reverse_proxy = {
  day1_backend = {
    path = "load-balancing haproxy backend day1"
    configs = {
      "mode"                = "tcp"
      "server day1 address" = "192.168.255.10"
      "server day1 port"    = "443"
      # Send the PROXY protocol
      "server day1 send-proxy-v2" = ""
    }
  }
  day2_backend = {
    path = "load-balancing haproxy backend day2"
    configs = {
      "mode"                = "tcp"
      "server day2 address" = "192.168.255.20"
      "server day2 port"    = "443"
      # Send the PROXY protocol
      "server day2 send-proxy-v2" = ""
    }
  }
  day1_frontend_zot = {
    path = "load-balancing haproxy service tcp443 rule 100"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "zot.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_etcd = {
    path = "load-balancing haproxy service tcp443 rule 110"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "etcd-0.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 120"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_cockpit = {
    path = "load-balancing haproxy service tcp443 rule 130"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_lldap = {
    path = "load-balancing haproxy service tcp443 rule 140"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "lldap.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_dufs = {
    path = "load-balancing haproxy service tcp443 rule 150"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "dufs.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_minio_api = {
    path = "load-balancing haproxy service tcp443 rule 160"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "minio-api.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_minio_console = {
    path = "load-balancing haproxy service tcp443 rule 165"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "minio-console.day1.sololab"
      "set backend" = "day1"
    }
  }
  # day1_frontend_sftpgo = {
  #   path = "load-balancing haproxy service tcp443 rule 160"
  #   configs = {
  #     "ssl"         = "req-ssl-sni"
  #     "domain-name" = "sftpgo.day1.sololab"
  #     "set backend" = "day1"
  #   }
  # }
  # day1_frontend_whoami = {
  #   path = "load-balancing haproxy service tcp443 rule 170"
  #   configs = {
  #     "ssl"         = "req-ssl-sni"
  #     "domain-name" = "whoami.day1.sololab"
  #     "set backend" = "day1"
  #   }
  # }
  day1_frontend_consul = {
    path = "load-balancing haproxy service tcp443 rule 180"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "consul-client.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_podman_exporter = {
    path = "load-balancing haproxy service tcp443 rule 190"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus-podman-exporter.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_alloy = {
    path = "load-balancing haproxy service tcp443 rule 191"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "alloy.day1.sololab"
      "set backend" = "day1"
    }
  }
  day1_frontend_vault = {
    path = "load-balancing haproxy service tcp443 rule 200"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "vault.day1.sololab"
      "set backend" = "vault"
    }
  }
  day1_backend_vault = {
    path = "load-balancing haproxy backend vault"
    configs = {
      "mode"                       = "tcp"
      "server vault address"       = "192.168.255.10"
      "server vault port"          = "8200"
      "server vault send-proxy-v2" = ""
    }
  }
  day1_frontend_pd = {
    path = "load-balancing haproxy service tcp443 rule 205"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "pd.day1.sololab"
      "set backend" = "day1"
    }
  }
  day2_frontend_consul = {
    path = "load-balancing haproxy service tcp443 rule 210"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "consul.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 220"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_nomad = {
    path = "load-balancing haproxy service tcp443 rule 230"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "nomad.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_grafana = {
    path = "load-balancing haproxy service tcp443 rule 240"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "grafana.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_loki = {
    path = "load-balancing haproxy service tcp443 rule 250"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "loki.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_prometheus = {
    path = "load-balancing haproxy service tcp443 rule 260"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus.day2.sololab"
      "set backend" = "day2"
    }
  }
  day2_frontend_prometheus_blackbox_exporter = {
    path = "load-balancing haproxy service tcp443 rule 261"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "prometheus-blackbox-exporter.day2.sololab"
      "set backend" = "day2"
    }
  }
  day3_frontend_redis_insight = {
    path = "load-balancing haproxy service tcp443 rule 270"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "redis-insight.day3.sololab"
      "set backend" = "day2"
    }
  }
  day3_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 300"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day3.sololab"
      "set backend" = "day2"
    }
  }
  day3_frontend_pgweb = {
    path = "load-balancing haproxy service tcp443 rule 310"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "pgweb.day3.sololab"
      "set backend" = "day2"
    }
  }
  day3_frontend_meilisearch = {
    path = "load-balancing haproxy service tcp443 rule 320"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "meilisearch.day3.sololab"
      "set backend" = "day2"
    }
  }
  day4_frontend_traefik = {
    path = "load-balancing haproxy service tcp443 rule 400"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day4.sololab"
      "set backend" = "day2"
    }
  }
  day4_frontend_gitea = {
    path = "load-balancing haproxy service tcp443 rule 410"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "gitea.day4.sololab"
      "set backend" = "day2"
    }
  }
  # day4_frontend_gitblit = {
  #   path = "load-balancing haproxy service tcp443 rule 410"
  #   configs = {
  #     "ssl"         = "req-ssl-sni"
  #     "domain-name" = "gitblit.day4.sololab"
  #     "set backend" = "day2"
  #   }
  # }
  day4_frontend_nexus = {
    path = "load-balancing haproxy service tcp443 rule 420"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "nexus.day4.sololab"
      "set backend" = "day2"
    }
  }
  day4_frontend_jenkins = {
    path = "load-balancing haproxy service tcp443 rule 430"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "jenkins.day4.sololab"
      "set backend" = "day2"
    }
  }
}
