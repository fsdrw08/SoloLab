resource "vault_identity_oidc" "server" {
  issuer = "https://vault.infra.sololab:8200"
}

# ref: https://github.com/Cottand/selfhosted/blob/aa04e9419ad8ad8830105537293beb71a363e4eb/terraform/nomad-sso/vault-oidc.tf#L90
resource "vault_identity_oidc_scope" "groups" {
  name     = "groups"
  template = <<EOF
  {
    "groups": {{identity.entity.groups.names}}
  }
  EOF
}

resource "vault_identity_oidc_scope" "username" {
  name     = "username"
  template = <<EOF
  {
    "username": {{identity.entity.name}}
  }
  EOF
}

resource "vault_identity_oidc_provider" "provider" {
  depends_on = [
    vault_identity_oidc_scope.groups,
    vault_identity_oidc_scope.username
  ]
  name          = "sololab"
  https_enabled = true
  # issuer_host   = "vault.service.consul"
  scopes_supported = [
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.username.name
  ]
  allowed_client_ids = [
    "*"
  ]
}
