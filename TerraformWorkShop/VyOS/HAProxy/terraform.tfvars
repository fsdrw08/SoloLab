prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

services = {
  tcp5432 = {
    path = "load-balancing haproxy service tcp5432"
    configs = {
      "mode" = "tcp"
      "port" = "5432"
    }
  }
}

reverse_proxy = {
  zot_frontend = {
    # path = "load-balancing reverse-proxy service tcp443 rule 30"
    path = "load-balancing haproxy service tcp443 rule 30"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "zot.day0.sololab"
      "set backend" = "zot_http"
    }
  }
  zot_backend = {
    path = "load-balancing haproxy backend zot_http"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  tfbackend_pg_frontend = {
    path = "load-balancing haproxy service tcp5432 rule 10"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "tfbackend-pg.day0.sololab"
      "set backend" = "tfbackend_pg"
    }
  }
  tfbackend_pg_backend = {
    path = "load-balancing haproxy backend tfbackend_pg"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "5432"
    }
  }
  etcd_frontend = {
    path = "load-balancing haproxy service tcp443 rule 40"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "etcd-0.day0.sololab"
      "set backend" = "etcd_http"
    }
  }
  etcd_backend = {
    path = "load-balancing haproxy backend etcd_http"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  traefik_day0_frontend = {
    path = "load-balancing haproxy service tcp443 rule 50"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "traefik.day0.sololab"
      "set backend" = "traefik_day0_http"
    }
  }
  traefik_day0_backend = {
    path = "load-balancing haproxy backend traefik_day0_http"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  cockpit_frontend = {
    path = "load-balancing haproxy service tcp443 rule 60"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.day0.sololab"
      "set backend" = "cockpit_http"
    }
  }
  cockpit_backend = {
    path = "load-balancing haproxy backend cockpit_http"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
  lldap_frontend = {
    path = "load-balancing haproxy service tcp443 rule 70"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "lldap.day0.sololab"
      "set backend" = "lldap_http"
    }
  }
  lldap_backend = {
    path = "load-balancing haproxy backend lldap_http"
    configs = {
      "mode"                = "tcp"
      "server day0 address" = "192.168.255.10"
      "server day0 port"    = "443"
    }
  }
}
