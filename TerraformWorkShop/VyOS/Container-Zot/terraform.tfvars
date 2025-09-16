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

runas = {
  take_charge = false
  user        = "vyos"
  uid         = 1002
  group       = "users"
  gid         = 100
}
