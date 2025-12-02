prov_system = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

prov_vyos = {
  url = "https://api.vyos.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

owner = {
  uid = 100
  gid = 1000
}
