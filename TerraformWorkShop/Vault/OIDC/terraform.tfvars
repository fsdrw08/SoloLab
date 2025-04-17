prov_vault = {
  address         = "https://vault.day0.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  issuer_host = "vault.day0.sololab"
  scopes = [
    {
      name     = "groups"
      template = <<-EOT
      {
        "groups": {{identity.entity.groups.names}}
      }
      EOT
    },
    {
      name     = "minio_scope"
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
    name         = "example-app"
    allow_groups = ["app-minio-admin"]
    redirect_uris = [
      "http://example-app.day0.sololab/callback",
    ]
  },
  {
    name         = "minio"
    allow_groups = ["app-minio-admin"]
    redirect_uris = [
      "https://minio-console.day0.sololab/oauth_callback",
    ]
  },
  {
    name         = "nomad"
    allow_groups = ["app-nomad-admin"]
    redirect_uris = [
      "https://nomad.day1.sololab/oidc/callback",
      "https://nomad.day1.sololab/ui/settings/tokens",
    ]
  },
]
