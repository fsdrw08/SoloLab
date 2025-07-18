data "vault_identity_oidc_openid_config" "config" {
  name = "sololab"
}

data "vault_identity_oidc_client_creds" "creds" {
  name = "nomad"
}

data "vault_kv_secret_v2" "ca" {
  mount = "kvv2/certs"
  name  = "root"
}

# https://developer.hashicorp.com/nomad/api-docs/acl/auth-methods#create-auth-method
resource "nomad_acl_auth_method" "oidc" {
  name           = "Vault"
  type           = "OIDC"
  default        = true
  token_locality = "global"
  # https://developer.hashicorp.com/nomad/api-docs/acl/auth-methods#tokennameformat
  token_name_format = "$${value.user}"
  max_token_ttl     = "15h0m0s"

  # https://developer.hashicorp.com/nomad/tutorials/single-sign-on/sso-oidc-vault#configure-nomad-oidc-auth
  # https://developer.hashicorp.com/nomad/api-docs/acl/auth-methods#config
  # https://github.com/datasektionen/infra/blob/6eb148550db55e1199756fa787307e29b9092f21/nomad.tf#L153
  config {
    oidc_discovery_url = data.vault_identity_oidc_openid_config.config.issuer
    discovery_ca_pem   = [data.vault_kv_secret_v2.ca.data["ca"]]
    oidc_client_id     = data.vault_identity_oidc_client_creds.creds.client_id
    oidc_client_secret = data.vault_identity_oidc_client_creds.creds.client_secret
    bound_audiences    = [data.vault_identity_oidc_client_creds.creds.client_id]
    oidc_scopes        = ["user", "groups"]
    allowed_redirect_uris = [
      "https://nomad.day0.sololab/oidc/callback",
      "https://nomad.day0.sololab/ui/settings/tokens",
    ]
    claim_mappings = {
      "username" = "user"
    }
    list_claim_mappings = {
      "groups" : "roles"
    }
  }
}

resource "nomad_acl_policy" "admin" {
  name        = "admin"
  description = "admin policy"

  rules_hcl = <<EOT
namespace "*" {
  policy = "write"
}

node {
  policy = "write"
}

agent {
  policy = "write"
}

operator {
  policy = "write"
}

quota {
  policy = "write"
}

# this is a host_volume rule, with a wildcard label
host_volume "*" {
  policy = "write"
}

plugin {
  policy = "write"
}
EOT
}

resource "nomad_acl_role" "admin" {
  name        = "app-nomad-admin"
  description = "admin role"

  policy {
    name = nomad_acl_policy.admin.name
  }
}

resource "nomad_acl_binding_rule" "admin" {
  description = "admin binding rule"
  auth_method = nomad_acl_auth_method.oidc.name
  bind_type   = "role"
  bind_name   = nomad_acl_role.admin.name
  selector    = "\"app-nomad-admin\" in list.roles"
}
