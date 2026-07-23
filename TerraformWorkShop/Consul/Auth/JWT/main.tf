data "vault_kv_secret_v2" "ca_cert" {
  mount = "kvv2_certs"
  name  = "sololab_root"
}

resource "consul_acl_auth_method" "jwt" {
  for_each = {
    for config in var.jwt_auth_configs : config.name => config
  }
  name = each.value.name
  type = "jwt"

  # https://developer.hashicorp.com/consul/docs/secure/acl/auth-method/jwt#config-parameters
  config_json = jsonencode({
    JWKSCACert = data.vault_kv_secret_v2.ca_cert.data["ca"]
    # ref: https://github.com/gitrgoliveira/vault-consul-auth/blob/356687425d9ee5bbdc03134e372e9b16a5791a07/consul.tf
    # https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#verifying-authenticity-of-id-tokens-generated-by-vault
    # https://developer.hashicorp.com/vault/api-docs/secret/identity/tokens#read-the-openid-configuration-from-an-identity-token-issuer
    JWKSURL          = each.value.config.JWKSURL
    JWTSupportedAlgs = each.value.config.JWTSupportedAlgs
    # This address must point to the identity/oidc path for the auth provider
    # (e.g. https://vault-1.example.com:8200/v1/identity/oidc) 
    # https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#issuer-considerations
    BoundIssuer    = each.value.config.BoundIssuer
    BoundAudiences = each.value.config.BoundAudiences
    # Mappings of claims (key) that will be copied to a metadata field (value). Use this if the claim you are capturing is singular (such as an attribute).
    # When mapped, the values can be any of a number, string, or boolean and will all be stringified when returned.
    # https://developer.hashicorp.com/consul/docs/security/acl/auth-methods/jwt#config-parameters
    # https://developer.hashicorp.com/consul/docs/security/acl/auth-methods/jwt#trusted-identity-attributes-via-claim-mappings
    ClaimMappings     = each.value.config.ClaimMappings
    ListClaimMappings = each.value.config.ListClaimMappings
  })
}

locals {
  acl_binding_rules = flatten([
    for config in var.jwt_auth_configs : [
      for binding_rule in config.binding_rules : {
        iac_id      = binding_rule.iac_id
        auth_name   = config.name
        bind_type   = binding_rule.bind_type
        bind_name   = binding_rule.bind_name
        selector    = binding_rule.selector
        description = binding_rule.description
      }
    ]
  ])
}

resource "consul_acl_binding_rule" "binding" {
  for_each = {
    for acl_binding_rule in local.acl_binding_rules : acl_binding_rule.iac_id => acl_binding_rule
  }
  auth_method = each.value.auth_name
  bind_type   = each.value.bind_type
  bind_name   = each.value.bind_name
  selector    = each.value.selector
}
