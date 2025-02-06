## consul jwt auth
# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "consul_jwt_auth" {
  name = "Consul-JWT_auth"
  key  = vault_identity_oidc_key.key.name
  ttl  = 3600 # 1h
  # The value for matching the aud field of the JSON web token (JWT)
  # need to set the same value in consul consul_acl_auth_method config_json.BoundAudiences
  # ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
  client_id = "consul-jwt-auth"
  template  = <<EOT
  {
    "username": {{identity.entity.name}},
    "groups": {{identity.entity.groups.names}}
  }
  EOT
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "consul_jwt_auth" {
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = vault_identity_oidc_role.consul_jwt_auth.client_id
}

# config policy to make the user who permission granted allow to config meta data in it's own
module "consul_jwt_auth_policy_bindings" {
  source = "../../../modules/vault-policy_binding"
  policy_bindings = [{
    policy_name     = "Consul-JWT_auth"
    policy_content  = <<-EOT
      path "identity/oidc/token/Consul-JWT_auth" {
        capabilities = ["read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read", "update"]
      }
      EOT
    policy_group    = "Policy-Consul-JWT_auth"
    external_groups = ["App-Consul-User"]
  }]

}

