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

resource "nomad_acl_auth_method" "oidc" {
  name           = "OIDC"
  type           = "OIDC"
  default        = true
  token_locality = "global"
  max_token_ttl  = "15h0m0s"

  config {
    oidc_discovery_url = data.vault_identity_oidc_openid_config.config.issuer
    discovery_ca_pem   = [data.vault_kv_secret_v2.ca.data["ca"]]
    oidc_client_id     = data.vault_identity_oidc_client_creds.creds.client_id
    oidc_client_secret = data.vault_identity_oidc_client_creds.creds.client_secret
    bound_audiences    = [data.vault_identity_oidc_client_creds.creds.client_id]
    oidc_scopes        = ["groups"]
    allowed_redirect_uris = [
      "https://nomad.day1.sololab/oidc/callback",
      "https://nomad.day1.sololab/ui/settings/tokens",
    ]
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
  name        = "App-Nomad-Admin"
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
  selector    = "\"App-Nomad-Admin\" in list.roles"
}
