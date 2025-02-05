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
    JWKSURL          = "${var.prov_vault.address}/v1/identity/oidc/.well-known/keys"
    JWTSupportedAlgs = ["RS256"]
    BoundIssuer      = "${var.prov_vault.address}/v1/identity/oidc"
    BoundAudiences   = ["consul-jwt-auth"]
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

data "consul_acl_policy" "admin" {
  name = "global-management"
}

resource "consul_acl_role" "role" {
  name        = "admin-role"
  description = "Role for consul admin"

  policies = [
    data.consul_acl_policy.admin.id
  ]
}

resource "consul_acl_binding_rule" "binding" {
  auth_method = consul_acl_auth_method.vault_jwt.name
  bind_type   = "role"
  bind_name   = consul_acl_role.role.name
  # ref: https://support.hashicorp.com/hc/en-us/articles/19385891472787-How-to-Configure-Consul-with-Okta
  selector = "\"App-Consul-Admin\" in list.groups"
}
