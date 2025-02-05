resource "vault_identity_oidc" "server" {
  issuer = var.prov_vault.address
}

# a jwt token usually include: 
# - openid base information (base scope): iss, sub, aud, iat, exp
# - provider level information (provider level scope, this block), see https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
# - role level information (aka token template), see https://developer.hashicorp.com/vault/docs/secrets/identity/identity-token#token-contents-and-templates
# ref: https://developer.hashicorp.com/vault/docs/concepts/oidc-provider#scopes
# ref: https://github.com/Cottand/selfhosted/blob/aa04e9419ad8ad8830105537293beb71a363e4eb/terraform/nomad-sso/vault-oidc.tf#L90
resource "vault_identity_oidc_scope" "scopes" {
  for_each = {
    for scope in var.oidc_provider.scopes : scope.name => scope
  }
  name     = each.value.name
  template = each.value.template
}

resource "vault_identity_oidc_provider" "provider" {
  depends_on = [
    vault_identity_oidc_scope.scopes,
    # vault_identity_oidc_scope.username
  ]
  name          = "sololab"
  https_enabled = true
  # issuer_host   = "vault.service.consul"
  scopes_supported = [
    for scope in var.oidc_provider.scopes : scope.name
  ]
  allowed_client_ids = [
    "*"
  ]
}
