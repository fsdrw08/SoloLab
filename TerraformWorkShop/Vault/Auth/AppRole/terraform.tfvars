prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

approles = [
  {
    role_name      = "consul-connect-pki"
    role_id        = "consul-connect-pki"
    token_policies = ["consul-ca"]
    secret_version = 1
  },
  {
    role_name      = "atlantis-operator"
    role_id        = "atlantis-operator"
    token_policies = ["vault-admin"]
    secret_version = 1
  },
  {
    role_name      = "pipeline-operator"
    role_id        = "pipeline-operator"
    token_policies = ["vault-admin"]
    secret_version = 1
  }
]

vault_secret_backend = "kvv2_vault"
