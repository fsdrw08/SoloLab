vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

runas = {
  user        = "vyos"
  group       = "users"
  uid         = 1002
  gid         = 100
  take_charge = false
}

data_dirs = "/mnt/data/zot"

container = {
  network = {
    create      = true
    name        = "zot"
    cidr_prefix = "172.16.4.0/24"
    address     = "172.16.4.10"
  }
  workload = {
    name        = "zot"
    image       = "ghcr.io/project-zot/zot-linux-amd64:v2.1.1" # quay.io/giantswarm/zot-linux-amd64:v2.1.1
    local_image = "/mnt/data/offline/images/ghcr.io_project-zot_zot-linux-amd64_v2.1.1.tar"
    others = {
      "network zot address" = "172.16.4.10"

      "uid" = "1002"
      "gid" = "100"

      "environment TZ value" = "Asia/Shanghai"
      # https://github.com/project-zot/zot/issues/2298
      # https://github.com/aquasecurity/trivy/issues/4169
      # https://github.com/aquasecurity/trivy/discussions/4194
      "environment SSL_CERT_DIR value" = "/etc/zot/certs"

      "volume zot_config source"      = "/etc/zot"
      "volume zot_config destination" = "/etc/zot"
      "volume zot_config mode"        = "ro"
      "volume zot_data source"        = "/mnt/data/zot"
      "volume zot_data destination"   = "/var/lib/registry"
    }
  }
}

reverse_proxy = {
  web_frontend = {
    # path = "load-balancing reverse-proxy service tcp443 rule 40"
    path = "load-balancing haproxy service tcp443 rule 40"
    configs = {
      "ssl"         = "req-ssl-sni"
      "domain-name" = "zot.mgmt.sololab"
      "set backend" = "zot_web"
    }
  }
  web_backend = {
    path = "load-balancing haproxy backend zot_web"
    configs = {
      "mode"                = "tcp"
      "server vyos address" = "172.16.4.10"
      "server vyos port"    = "5000"
    }
  }
}

dns_record = {
  host = "zot.mgmt.sololab"
  ip   = "192.168.255.1"
}
