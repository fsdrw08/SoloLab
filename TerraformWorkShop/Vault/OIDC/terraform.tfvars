prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer_host = "vault.day1.sololab"
  scopes = [
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
    allow_groups = ["App-Nomad-Admin"]
    redirect_uris = [
      "https://nomad.day1.sololab/oidc/callback",
      "https://nomad.day1.sololab/ui/settings/tokens",
    ]
  },
  # {
  #   name         = "minio"
  #   allow_groups = ["App-MinIO-Admin"]
  #   redirect_uris = [
  #     "https://minio.service.sololab/ui/oauth_callback",
  #   ]
  # },
]
