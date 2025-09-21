prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

reverse_proxy = {
  day0_zot_frontend = {
    path = "load-balancing haproxy service tcp443 rule 100"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "zot.day0.sololab"
      "set backend" = "day0_zot"
    }
  }
  day0_zot_backend = {
    path = "load-balancing haproxy backend day0_zot"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  day0_etcd_frontend = {
    path = "load-balancing haproxy service tcp443 rule 110"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "etcd-0.day0.sololab"
      "set backend" = "day0_etcd"
    }
  }
  day0_etcd_backend = {
    path = "load-balancing haproxy backend day0_etcd"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  day0_traefik_frontend = {
    path = "load-balancing haproxy service tcp443 rule 120"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day0.sololab"
      "set backend" = "day0_traefik"
    }
  }
  day0_traefik_backend = {
    path = "load-balancing haproxy backend day0_traefik"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  day0_cockpit_frontend = {
    path = "load-balancing haproxy service tcp443 rule 130"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.day0.sololab"
      "set backend" = "day0_cockpit"
    }
  }
  day0_cockpit_backend = {
    path = "load-balancing haproxy backend day0_cockpit"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  day0_lldap_frontend = {
    path = "load-balancing haproxy service tcp443 rule 140"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "lldap.day0.sololab"
      "set backend" = "day0_lldap"
    }
  }
  day0_lldap_backend = {
    path = "load-balancing haproxy backend day0_lldap"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
}
