data "vault_identity_group" "minio_default" {
  group_name = "minio-default"
}

# ref: https://github.com/tfo-apj-demos/terraform-vault-tfo-apj-demo-admin/blob/67e469df712eb7a582cd61fba86823c11a8b1d26/22%20-%20identity_oidc_provider.tf#L22
# https://developer.hashicorp.com/vault/api-docs/secret/identity/oidc-provider#key
# A reference to a named key resource. This key will be used to sign ID tokens for the client. 
# This cannot be modified after creation. If not supplied, defaults to the built-in default key.
resource "vault_identity_oidc_key" "minio" {
  name             = "minio"
  algorithm        = "RS256"
  verification_ttl = 7200
  rotation_period  = 7200
}

# Creates an Identity OIDC Role for Vault Identity secrets engine to issue identity tokens.
# about identity token: https://www.vaultproject.io/docs/secrets/identity/index.html#identity-tokens/
resource "vault_identity_oidc_role" "minio" {
  name = "minio"
  key  = vault_identity_oidc_key.minio.name
  ttl  = 60
}

# bind role and key together
resource "vault_identity_oidc_key_allowed_client_id" "minio" {
  key_name          = vault_identity_oidc_key.minio.name
  allowed_client_id = vault_identity_oidc_client.minio.client_id
}

# The assignments parameter limits the Vault entities and groups that are allowed to authenticate through the client application. 
# By default, no Vault entities are allowed. To allow all Vault entities to authenticate, the built-in allow_all assignment is provided.
resource "vault_identity_oidc_assignment" "minio" {
  name = "oidc-minio"
  group_ids = [
    data.vault_identity_group.minio_default.group_id
  ]
}

# client means the external application, the application needs the client id and client secret,
# which provider by this block
resource "vault_identity_oidc_client" "minio" {
  name = "minio"
  redirect_uris = [
    "https://minio.service.consul/oauth_callback"
  ]
  assignments = [
    vault_identity_oidc_assignment.minio.name
  ]
  id_token_ttl     = 2400
  access_token_ttl = 7200
  key              = vault_identity_oidc_key.minio.id

}

resource "vault_identity_oidc_scope" "minio_groups" {
  name     = "groups"
  template = "{\"groups\" :{{identity.entity.groups.names}} }"
}

resource "vault_identity_oidc_scope" "minio_username" {
  name     = "username"
  template = "{\"username\":{{identity.entity.name}}}"
}

resource "vault_identity_oidc_provider" "minio" {
  name          = "minio"
  https_enabled = true
  issuer_host   = "vault.service.consul:8200"
  scopes_supported = [
    vault_identity_oidc_scope.minio_groups.name,
    vault_identity_oidc_scope.minio_username.name
  ]
  allowed_client_ids = [
    vault_identity_oidc_client.minio.client_id
  ]
}
