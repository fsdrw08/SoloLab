prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

reverse_proxy = {
  day0_backend = {
    path = "load-balancing haproxy backend day0"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
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
}
