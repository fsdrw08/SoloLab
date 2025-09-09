# ref: https://github.com/tfo-apj-demos/terraform-vault-tfo-apj-demo-admin/blob/67e469df712eb7a582cd61fba86823c11a8b1d26/22%20-%20identity_oidc_provider.tf#L22
# https://developer.hashicorp.com/vault/api-docs/secret/identity/oidc-provider#key
# A reference to a named key resource. This key will be used to sign ID tokens for the client. 
# This cannot be modified after creation. If not supplied, defaults to the built-in default key.
resource "vault_identity_oidc_key" "consul_auto_config" {
  name             = "consul-auto_config"
  algorithm        = "RS256"
  verification_ttl = 3600
  rotation_period  = 3600
}

# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "consul_auto_config" {
  name      = "consul-auto_config"
  key       = vault_identity_oidc_key.consul_auto_config.name
  ttl       = 3600 # 1h
  client_id = "consul-cluster-dc1"
  template  = <<EOT
  {
    "consul": {
      "hostname": {{identity.entity.metadata.consul_agent}}
    }
  }
  EOT
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "consul_auto_config" {
  key_name          = vault_identity_oidc_key.consul_auto_config.name
  allowed_client_id = vault_identity_oidc_role.consul_auto_config.client_id
}

# vault policy to allow user update self's metadata
resource "vault_policy" "consul_auto_config" {
  name   = "consul-auto_config"
  policy = <<-EOT
  path "identity/oidc/token/consul_auto_config" {
    capabilities = ["read"]
  }
  path "identity/entity/id" {
    capabilities = ["list"]
  }
  path "identity/entity/id/{{identity.entity.id}}" {
    capabilities = ["read", "update"]
  }
  EOT
}

# vault identity group for the policy
resource "vault_identity_group" "consul_auto_config" {
  name                       = "policy-consul-auto_config"
  type                       = "internal"
  external_policies          = true
  external_member_group_ids  = true
  external_member_entity_ids = true
}

resource "vault_identity_group_policies" "consul_auto_config" {
  policies = [
    vault_policy.consul_auto_config.name
  ]

  exclusive = true

  group_id = vault_identity_group.consul_auto_config.id
}
