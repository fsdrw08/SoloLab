prov_system = {
  host     = "192.168.255.20"
  port     = 22
  user     = "core"
  password = "P@ssw0rd"
  sudo     = true
}

prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}
