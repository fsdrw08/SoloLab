prov_vault = {
  address         = "https://vault.day1.sololab"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

oidc_provider = {
  name        = "sololab"
  issuer_host = "vault.day1.sololab"
  # https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
  scopes = [
    {
      name = "user"
      # metadata config in Vault/Auth/LDAP/main.tf vault_identity_entity.user metadata
      template = <<-EOT
      {
        "username": {{identity.entity.name}},
        "uid": {{identity.entity.metadata.uid}},
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
    name         = "minio"
    allow_groups = ["app-minio-user"]
    redirect_uris = [
      "https://minio-console.day1.sololab/oauth_callback",
    ]
  },
  {
    name         = "nomad"
    allow_groups = ["app-nomad-user"]
    redirect_uris = [
      "https://nomad.day2.sololab/oidc/callback",
      "https://nomad.day2.sololab/ui/settings/tokens",
    ]
  },
  {
    name         = "grafana"
    allow_groups = ["app-grafana-user"]
    redirect_uris = [
      "https://grafana.day2.sololab/login/generic_oauth",
    ]
  },
  {
    name         = "gitea"
    allow_groups = ["app-gitea-user"]
    redirect_uris = [
      # https://www.authelia.com/integration/openid-connect/clients/gitea/#assumptions
      "https://gitea.day4.sololab/user/oauth2/Vault/callback",
    ]
  },
  {
    name         = "jenkins"
    allow_groups = ["app-jenkins-user"]
    redirect_uris = [
      "https://jenkins.day4.sololab/securityRealm/finishLogin",
    ]
  },
]

vault_secret_backend = "kvv2_vault"
