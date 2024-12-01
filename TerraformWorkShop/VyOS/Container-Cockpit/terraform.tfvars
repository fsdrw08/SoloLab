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

certs = {
  dir                         = "/etc/cockpit/ws-certs.d"
  cert_content_tfstate_ref    = "../../TLS/RootCA/terraform.tfstate"
  cert_content_tfstate_entity = "cockpit"
}

container = {
  network = {
    create      = true
    name        = "cockpit"
    cidr_prefix = "172.16.5.0/24"
    address     = "172.16.5.10"
  }
  workload = {
    name = "cockpit"
    # image       = "quay.io/cockpit/ws:329"
    # local_image = "/mnt/data/offline/images/quay.io_cockpit_ws_329.tar"
    image     = "zot.day0.sololab/cockpit/ws:329"
    pull_flag = "--tls-verify=false"
    others = {
      "network cockpit address" = "172.16.5.10"
      "environment TZ value"    = "Asia/Shanghai"

      "volume cockpit_cert source"      = "/etc/cockpit/ws-certs.d"
      "volume cockpit_cert destination" = "/etc/cockpit/ws-certs.d"
    }
  }
}

dns_record = {
  host = "cockpit.day0.sololab"
  ip   = "192.168.255.1"
}

reverse_proxy = {
  web_frontend = {
    # path = "load-balancing reverse-proxy service tcp443 rule 50" # vyos 1.4
    path = "load-balancing haproxy service tcp443 rule 50" # vyos 1.5
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "cockpit.day0.sololab"
      "set backend" = "cockpit_web"
    }
  }
  web_backend = {
    path = "load-balancing haproxy backend cockpit_web"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.5.10"
      "server vyos port"    = "9090"
    }
  }
}
