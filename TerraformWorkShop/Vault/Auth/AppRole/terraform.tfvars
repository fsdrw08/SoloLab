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
    role_name      = "jenkins-secret-reader"
    role_id        = "jenkins-secret-reader"
    token_policies = ["jenkins-secret-reader"]
    secret_version = 1
  }
]

vault_secret_backend = "kvv2_vault"
