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
  day0_frontend_dufs = {
    path = "load-balancing haproxy service tcp443 rule 150"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "dufs.day0.sololab"
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
  day1_frontend_vault = {
    path = "load-balancing haproxy service tcp443 rule 200"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "vault.day1.sololab"
      "set backend" = "day1"
    }
  }
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
}
