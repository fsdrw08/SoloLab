prov_system = {
  host     = "192.168.255.20"
  port     = 22
  user     = "core"
  password = "P@ssw0rd"
  sudo     = false
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}
