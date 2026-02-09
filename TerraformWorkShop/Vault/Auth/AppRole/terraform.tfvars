prov_vault = {
  address         = "https://vault.day0.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

approles = [
  {
    role_name      = "consul-connect-pki"
    role_id        = "consul-connect-pki"
    token_policies = ["consul-ca"]
  }
]

vault_secret_backend = "kvv2_vault"
