prov_vault = {
  address         = "https://vault.day1.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer = "https://vault.infra.sololab:8200"
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
      "https://nomad.day1.sololab:4649/oidc/callback",
      "https://nomad.day1.sololab:4646/ui/settings/tokens",
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
