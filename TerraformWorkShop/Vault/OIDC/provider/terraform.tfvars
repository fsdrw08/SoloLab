prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer = "https://vault.infra.sololab:8200"
  scopes = [
    {
      name     = "username"
      template = <<EOF
        {
          "username": {{identity.entity.name}}
        }
      EOF
    },
  ]
}
