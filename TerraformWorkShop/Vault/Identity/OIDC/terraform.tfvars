prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer_host = "vault.day1.sololab"
  # https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
  scopes = [
    {
      name     = "user"
      template = <<-EOT
      {
        "username": {{identity.entity.name}},
        "email": {{identity.entity.metadata.email}}
      }
      EOT
    },
    {
      name     = "groups"
      template = <<-EOT
      {
        "groups": {{identity.entity.groups.names}}
      }
      EOT
    },
  ]
}

oidc_client = [
  {
    name         = "nomad"
    allow_groups = ["app-nomad-user"]
    redirect_uris = [
      "https://nomad.day1.sololab/oidc/callback",
      "https://nomad.day1.sololab/ui/settings/tokens",
    ]
  },
  {
    name         = "grafana"
    allow_groups = ["app-grafana-user"]
    redirect_uris = [
      "https://grafana.day2.sololab/login/generic_oauth",
    ]
  },
]
