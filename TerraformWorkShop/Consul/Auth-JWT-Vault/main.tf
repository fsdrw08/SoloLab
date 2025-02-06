data "vault_kv_secret_v2" "ca_cert" {
  mount = "kvv2/certs"
  name  = "root"
}

resource "consul_acl_auth_method" "vault_jwt" {
  name = "vault-jwt"
  type = "jwt"

  config_json = jsonencode({
    JWKSCACert = data.vault_kv_secret_v2.ca_cert.data["ca"]
    # ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
    # https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#verifying-authenticity-of-id-tokens-generated-by-vault
    # https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#read-the-openid-configuration-from-an-identity-token-issuer
    JWKSURL          = "${var.prov_vault.address}/v1/identity/oidc/.well-known/keys"
    JWTSupportedAlgs = ["RS256"]
    # This address must point to the identity/oidc path for the Vault instance 
    # (e.g. https://vault-1.example.com:8200/v1/identity/oidc) 
    # https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#issuer-considerations
    BoundIssuer    = "${var.prov_vault.address}/v1/identity/oidc"
    BoundAudiences = ["consul-jwt-auth"]
    # Mappings of claims (key) that will be copied to a metadata field (value). Use this if the claim you are capturing is singular (such as an attribute).
    # When mapped, the values can be any of a number, string, or boolean and will all be stringified when returned.
    # https://developer.hashicorp.com/consul/docs/security/acl/auth-methods/jwt#config-parameters
    # https://developer.hashicorp.com/consul/docs/security/acl/auth-methods/jwt#trusted-identity-attributes-via-claim-mappings
    ClaimMappings = {
      "username" : "username",
    }
    ListClaimMappings = {
      "groups" : "groups"
    }
  })
}

# admin role
data "consul_acl_policy" "admin" {
  name = "global-management"
}

resource "consul_acl_role" "admin" {
  name        = "admin-role"
  description = "Role for consul admin"

  policies = [
    data.consul_acl_policy.admin.id
  ]
}

resource "consul_acl_binding_rule" "admin" {
  auth_method = consul_acl_auth_method.vault_jwt.name
  bind_type   = "role"
  bind_name   = consul_acl_role.admin.name
  # ref: https://support.hashicorp.com/hc/en-us/articles/19385891472787-How-to-Configure-Consul-with-Okta
  selector = "\"App-Consul-Admin\" in list.groups"
}

# user role (read only)
data "consul_acl_policy" "user" {
  name = "builtin/global-read-only"
}

resource "consul_acl_role" "user" {
  name        = "user-role"
  description = "Role for consul user (read only)"

  policies = [
    data.consul_acl_policy.user.id
  ]
}

resource "consul_acl_binding_rule" "user" {
  auth_method = consul_acl_auth_method.vault_jwt.name
  bind_type   = "role"
  bind_name   = consul_acl_role.user.name
  # ref: https://support.hashicorp.com/hc/en-us/articles/19385891472787-How-to-Configure-Consul-with-Okta
  selector = "\"App-Consul-User\" in list.groups"
}
