prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

mount = "kvv2_pgsql"

databases = [
  {
    name           = "exporter"
    user_name      = "exporter"
    secret_version = 1
  },
  {
    name           = "test"
    user_name      = "test"
    secret_version = 1
  },
]
