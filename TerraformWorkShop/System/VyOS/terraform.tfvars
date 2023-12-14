vm_conn = {
  host = "192.168.255.1"
  port = 22
  user = "vyos"
  password = "vyos"
}

consul_conn = {
  address = "192.168.255.2:8500"
  datacenter = "dc1"
  scheme = "http"
}

consul_version = "1.17.0"
consul_token_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
consul_conf = {
  bind_addr = "192.168.255.2"
  client_addr = "192.168.255.2"
  data_dir = "/mnt/data/consul"
}

stepca_version = "0.25.2"
stepcli_version = "0.25.1"
stepca_password = "P@ssw0rd"

traefik_version = "v2.10.7"