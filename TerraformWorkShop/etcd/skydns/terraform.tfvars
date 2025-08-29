prov_etcd = {
  endpoints = "https://192.168.255.10:2379"
  ca_cert   = "../../TLS/RootCA/root.crt"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = false
}

# https://coredns.io/plugins/etcd/
kv_pairs = [{
  key = "/skydns/sololab/day0/zot/"
  #   value = "{\"host\":\"192.168.255.10\",\"ttl\":60}"
  value = {
    host = "192.168.255.10"
    ttl  = 60
  }
}]
