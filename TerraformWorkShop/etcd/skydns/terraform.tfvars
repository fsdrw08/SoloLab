prov_etcd = {
  endpoints = "https://etcd-0.day0.sololab:2379"
  username  = "root"
  password  = "P@ssw0rd"
  skip_tls  = true
}

# https://coredns.io/plugins/etcd/
dns_records = [
  {
    hostname = "traefik.day0.sololab"
    value = {
      string_map = {
        host = "192.168.255.10"
      }
      number_map = {
        ttl = 60
      }
    }
  }
]
