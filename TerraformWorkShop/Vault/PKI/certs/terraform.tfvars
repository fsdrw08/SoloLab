prov_vault = {
  schema          = "https"
  address         = "vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

vault_kvv2 = {
  secret_engine = {
    path = "kvv2/certs"
  }
}

vault_certs = [
  {
    secret_engine = {
      backend   = "pki/day1"
      role_name = "IntCA-Day1-v1-role-default"
    }
    common_name = "opendj.day1.sololab"
    ttl_years   = 3
  },
]
