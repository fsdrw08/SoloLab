## Consul Auto config
# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "consul_auto_config" {
  name = "Consul-Auto_config"
  key  = vault_identity_oidc_key.key.name
  ttl  = 3600 # 1h
  # The value for matching the aud field of the JSON web token (JWT).
  # need to set the same value in Consul config file auto_config.authorization.static.bound_audiences
  # ref: https://developer.hashicorp.com/consul/tutorials/archive/docker-compose-auto-config#bound_audiences
  client_id = "consul-cluster-dc1"
  # JSON web tokens (JWTs) are generated against a role and signed against a named key. 
  # The template='{"consul": {"hostname": "consul-client" } }' will create additional JWT metadata 
  # that will be used by the Consul authorization servers to validate the request.
  # https://developer.hashicorp.com/consul/tutorials/archive/docker-compose-auto-config#configure-vault-to-generate-jwts
  template = <<EOT
  {
    "consul": {
      "hostname": {{identity.entity.metadata.consul_agent}}
    }
  }
  EOT
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "consul_auto_config" {
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = vault_identity_oidc_role.consul_auto_config.client_id
}

# config policy to make the user who permission granted allow to config meta data in it's own
module "consul_auto_config_policy_bindings" {
  source = "../../../modules/vault-policy_binding"
  policy_bindings = [{
    policy_name     = "Consul-Auto_config"
    policy_content  = <<-EOT
      path "identity/oidc/token/Consul-Auto_config" {
        capabilities = ["read"]
      }
      path "identity/entity/id" {
        capabilities = ["list"]
      }
      path "identity/entity/id/{{identity.entity.id}}" {
        capabilities = ["read", "update"]
      }
      EOT
    policy_group    = "Policy-Consul-auto_config"
    external_groups = ["App-Consul-Auto_Config"]
  }]

}


