vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

consul_post_process = {
  Config-ConsulDNS = {
    script_path = "./consul/Config-ConsulDNS.sh"
    vars = {
      # CONSUL_CACERT = 
      client_addr     = "192.168.255.1:8500"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
  }
  Update-vyOSDNS = {
    script_path = "./consul/Update-vyOSDNS.sh"
    vars = {
      domain = "consul"
      ip     = "192.168.255.2"
    }
  }
}
