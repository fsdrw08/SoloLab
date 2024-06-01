vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

reverse_proxy = {
  web_frontend = {
    path = "load-balancing reverse-proxy service http rule 10"
    configs = {
      "domain-name" = "files.mgmt.sololab"
      "set backend" = "files"
    }
  }
  web_backend = {
    path = "load-balancing reverse-proxy backend files"
    configs = {
      "mode"                = "http"
      "server vyos address" = "192.168.255.1"
      "server vyos port"    = "8080"
    }
  }
}

dns_record = {
  host = "files.mgmt.sololab"
  ip   = "192.168.255.1"
}
