## consul jwt auth
# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "consul_jwt_auth" {
  name = "consul_jwt_auth"
  key  = vault_identity_oidc_key.key.name
  ttl  = 3600 # 1h
  # The value for matching the aud field of the JSON web token (JWT)
  # need to set the same value in consul consul_acl_auth_method config_json.BoundAudiences
  # ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
  client_id = "consul-jwt-auth"
  template  = <<EOT
  {
    "entity_name": {{identity.entity.name}},
  }
  EOT
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "consul_jwt_auth" {
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = vault_identity_oidc_role.consul_jwt_auth.client_id
}
