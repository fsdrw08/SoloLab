resource "vault_identity_oidc" "server" {
  issuer = var.prov_vault.address
}

# a jwt token usually include: 
# - openid base information (base scope): iss, sub, aud, iat, exp
# - provider level information (provider level scope, this block), see https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
# - role level information (aka token template, but this only for jwt token auth), see https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#token-contents-and-templates
# ref: https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
# ref: https://github.com/Cottand/selfhosted/blob/aa04e9419ad8ad8830105537293beb71a363e4eb/terraform/nomad-sso/vault-oidc.tf#L90
resource "vault_identity_oidc_scope" "scopes" {
  for_each = {
    for scope in var.oidc_provider.scopes :
    scope.name => scope
  }
  name     = each.value.name
  template = each.value.template
}

# ! if delete scope, this provider resource will prevent scope delete
# no idea how to update this resource before scope destroy
resource "vault_identity_oidc_provider" "provider" {
  depends_on = [
    vault_identity_oidc_scope.scopes,
  ]
  name          = "sololab"
  https_enabled = true
  issuer_host   = var.oidc_provider.issuer_host
  # https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
  scopes_supported = [
    for scope in var.oidc_provider.scopes : scope.name
  ]
  allowed_client_ids = [
    "*"
  ]
}

# ref: https://github.com/tfo-apj-demos/terraform-vault-tfo-apj-demo-admin/blob/67e469df712eb7a582cd61fba86823c11a8b1d26/22%20-%20identity_oidc_provider.tf#L22
# https://developer.hashicorp.com/vault/api-docs/secret/identity/oidc-provider#key
# A reference to a named key resource. This key will be used to sign ID tokens for the client. 
# This cannot be modified after creation. If not supplied, defaults to the built-in default key.
resource "vault_identity_oidc_key" "key" {
  name             = "OIDC_Key"
  algorithm        = "RS256"
  verification_ttl = 7200
  rotation_period  = 7200
}

data "vault_identity_group" "group" {
  for_each = {
    for group in setunion(
      flatten([
        for client in var.oidc_client : client.allow_groups
    ])) : group => group
  }
  group_name = each.key
}

# The assignments parameter limits the Vault entities and groups that are allowed to authenticate through the client application. 
# By default, no Vault entities are allowed. To allow all Vault entities to authenticate, the built-in allow_all assignment is provided.
# ref: https://github.com/mekstack/mekstack/blob/d9df2e9b64db587256074114ea0ab5b6b4c6fb0a/infra/vault/vault.tf#L34
resource "vault_identity_oidc_assignment" "assignment" {
  for_each = {
    for client in var.oidc_client : client.name => client
  }
  name = each.key
  group_ids = [
    for group in each.value.allow_groups : data.vault_identity_group.group[group].group_id
  ]
}

# client means the external application, the application needs the client id and client secret,
# which provider by this block
resource "vault_identity_oidc_client" "client" {
  for_each = {
    for client in var.oidc_client : client.name => client
  }
  name          = each.key
  redirect_uris = each.value.redirect_uris
  assignments = [
    vault_identity_oidc_assignment.assignment[each.key].name
  ]
  id_token_ttl     = each.value.id_token_ttl
  access_token_ttl = each.value.access_token_ttl
  key              = vault_identity_oidc_key.key.id
}

# bind key and client together
resource "vault_identity_oidc_key_allowed_client_id" "allow" {
  for_each = {
    for client in var.oidc_client : client.name => client
  }
  key_name          = vault_identity_oidc_key.key.name
  allowed_client_id = vault_identity_oidc_client.client[each.key].client_id
}
