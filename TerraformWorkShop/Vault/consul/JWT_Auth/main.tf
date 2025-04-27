# ref: https://github.com/tfo-apj-demos/terraform-vault-tfo-apj-demo-admin/blob/67e469df712eb7a582cd61fba86823c11a8b1d26/22%20-%20identity_oidc_provider.tf#L22
# https://developer.hashicorp.com/vault/api-docs/secret/identity/oidc-provider#key
# A reference to a named key resource. This key will be used to sign ID tokens for the client. 
# This cannot be modified after creation. If not supplied, defaults to the built-in default key.
resource "vault_identity_oidc_key" "key" {
  name             = var.oidc_key.name
  algorithm        = var.oidc_key.algorithm
  verification_ttl = var.oidc_key.verification_ttl
  rotation_period  = var.oidc_key.rotation_period
}

# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "oidc_roles" {
  for_each = {
    for oidc_role in var.oidc_roles : oidc_role.name => oidc_role
  }
  name      = each.value.name
  key       = vault_identity_oidc_key.key.name
  ttl       = each.value.ttl
  client_id = each.value.client_id
  template  = each.value.template
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "oidc_key_allowed_client_ids" {
  for_each = {
    for oidc_role in var.oidc_roles : oidc_role.name => oidc_role
  }
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = vault_identity_oidc_role.oidc_roles[each.key].client_id
}

# config policy to make the user who permission granted allow to config meta data in it's own
module "consul_auto_config_policy_bindings" {
  source          = "../../../modules/vault-policy_binding"
  policy_bindings = var.policy_bindings

}

resource "vault_mount" "kvv2" {
  path        = "kvv2/consul"
  type        = "kv-v2"
  description = "kvv2 secret backend for consul"
}
