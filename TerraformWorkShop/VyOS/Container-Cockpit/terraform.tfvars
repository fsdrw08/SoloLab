vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

container = {
  network = {
    create      = true
    name        = "cockpit"
    cidr_prefix = "172.16.5.0/24"
    address     = "172.16.5.10"
  }
  workload = {
    name        = "cockpit"
    image       = "quay.io/cockpit/ws:316"
    local_image = "/mnt/data/offline/images/cockpit_ws_316.tar"
    others = {
      "environment TZ value" = "Asia/Shanghai"

      "volume cockpit_cert source"      = "/etc/cockpit/ws-certs.d"
      "volume cockpit_cert destination" = "/etc/cockpit/ws-certs.d"
    }
  }
}

dns_record = {
  host = "cockpit.mgmt.sololab"
  ip   = "192.168.255.1"
}

reverse_proxy = {
  web_frontend = {
    path = "load-balancing reverse-proxy service tcp443 rule 50"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.mgmt.sololab"
      "set backend" = "cockpit_web"
    }
  }
  web_backend = {
    path = "load-balancing reverse-proxy backend cockpit_web"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.5.10"
      "server vyos port"    = "9090"
    }
  }
}
