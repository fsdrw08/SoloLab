prov_system = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
  sudo     = true
}

prov_vault = {
  schema          = "https"
  address         = "vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

XDG_CONFIG_HOME = "/var/home/podmgr/.config"
bin_dir         = "/var/home/podmgr/.local/bin"
data_dir        = "/var/home/podmgr/.local/opt/consul/data"
