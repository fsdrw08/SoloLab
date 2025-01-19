# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
# https://developer.hashicorp.com/vault/docs/secrets/pki/setup#setup
resource "vault_mount" "pki" {
  # the "pki" prefix is the default mount path prefix for mount type of pki
  path                      = var.vault_pki.secret_engine.path
  type                      = "pki"
  description               = var.vault_pki.secret_engine.description
  default_lease_ttl_seconds = (var.vault_pki.secret_engine.default_lease_ttl_years * 365 * 24 * 60 * 60)
  max_lease_ttl_seconds     = (var.vault_pki.secret_engine.max_lease_ttl_years * 365 * 24 * 60 * 60)
}

resource "vault_pki_secret_backend_config_cluster" "config_cluster" {
  backend  = vault_mount.pki.path
  path     = "https://${var.prov_vault.address}/v1/${vault_mount.pki.path}"
  aia_path = "https://${var.prov_vault.address}/v1/${vault_mount.pki.path}"
}

# Enable Authority Information Access (AIA) templating
# Configure the Authority Information Access (AIA)
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca:~:text=The%20vault_pki_secret_backend_config_urls%20configures%20CA%20and%20CRL%20URLs
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls
# https://serverfault.com/questions/1023474/ocsp-setup-for-vault/1159997#1159997
# https://developer.hashicorp.com/vault/api-docs/secret/pki#ocsp-request
resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend           = vault_mount.pki.path
  enable_templating = true
  issuing_certificates = [
    "{{cluster_aia_path}}/issuer/{{issuer_id}}/der",
  ]
  crl_distribution_points = [
    "{{cluster_aia_path}}/issuer/{{issuer_id}}/crl/der",
  ]
  ocsp_servers = [
    "{{cluster_aia_path}}/ocsp",
  ]
}

# Certificate Revocation List (CRL)
resource "vault_pki_secret_backend_crl_config" "crl_config" {
  backend      = vault_mount.pki.path
  expiry       = "72h"
  disable      = false
  auto_rebuild = true
  enable_delta = true
}

#  for the Intermediate CA, we need to generate a role to consume the PKI secret engine as a client.
# Using the vault_pki_secret_backend_role resource creates a role for this CA; 
# creating this role allows for specifying an issuer when necessary for the purposes of this scenario. 
# This also provides a simple way to transition from one issuer to another by referring to it by name.
resource "vault_pki_secret_backend_role" "role" {
  backend = vault_mount.pki.path
  name    = var.vault_pki.role.name
  # https://developer.hashicorp.com/vault/api-docs/secret/pki#ext_key_usage
  # https://pkg.go.dev/crypto/x509#ExtKeyUsage
  ext_key_usage    = var.vault_pki.role.ext_key_usage
  ttl              = (var.vault_pki.role.ttl_years * 365 * 24 * 60 * 60) # years in seconds
  allow_ip_sans    = var.vault_pki.role.allow_ip_sans
  key_type         = var.vault_pki.role.key_type
  key_bits         = var.vault_pki.role.key_bits
  allowed_domains  = var.vault_pki.role.allowed_domains
  allow_subdomains = var.vault_pki.role.allow_subdomains
  allow_any_name   = var.vault_pki.role.allow_any_name
}


# intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_cert_request" {
  count       = var.vault_pki.ca.internal_sign == null ? 0 : 1
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = var.vault_pki.ca.internal_sign.common_name

}

data "vault_pki_secret_backend_issuers" "root_ca" {
  count   = var.vault_pki.ca.internal_sign == null ? 0 : 1
  backend = var.vault_pki.ca.internal_sign.backend
}

# sign cert by root ca
resource "vault_pki_secret_backend_root_sign_intermediate" "root_sign_intermediate" {
  count       = var.vault_pki.ca.internal_sign == null ? 0 : 1
  backend     = var.vault_pki.ca.internal_sign.backend
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_cert_request[0].csr
  common_name = var.vault_pki.ca.internal_sign.common_name
  issuer_ref  = element(keys(data.vault_pki_secret_backend_issuers.root_ca[0].key_info), 0)
  ttl         = (var.vault_pki.ca.internal_sign.ttl_years * 365 * 24 * 60 * 60) # years in seconds
}

# import intermediate cert to Vault
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_set_signed" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate[0].certificate
}

resource "vault_pki_secret_backend_issuer" "issuer" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_intermediate_set_signed.intermediate_set_signed.imported_issuers[0]
  revocation_signature_algorithm = var.vault_pki.issuer.revocation_signature_algorithm
  issuer_name                    = var.vault_pki.issuer.name
}

# acme
resource "vault_pki_secret_backend_role" "role_acme" {
  backend          = vault_mount.pki.path
  name             = "IntCA-Day1-v1-role-acme"
  ttl              = (60 * 60 * 24 * 91) # 91 days in seconds
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["day1.sololab", "day1.service.consul"]
  allow_subdomains = true
  allow_any_name   = true
}

# enable the acme configuration.
# https://www.infralovers.com/blog/2023-10-16-hashicorp-vault-acme-terraform-configuration/#:~:text=apply%20the%20secrets,1
#
# 202501: consider use vault_pki_secret_backend_config_acme instead 
# ref: https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#acme-certificate-issuance
# https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#set-acme-configuration
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_acme
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_acme
resource "vault_pki_secret_backend_config_acme" "config_acme" {
  backend         = vault_mount.pki.path
  enabled         = true
  allowed_roles   = [vault_pki_secret_backend_role.role_acme.name]
  allowed_issuers = [vault_pki_secret_backend_issuer.issuer.issuer_id]
}

# apply the secrets engine tuning parameter
# ref: https://developer.hashicorp.com/vault/api-docs/secret/pki#acme-required-headers
# https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#acme-required-headers
resource "vault_generic_endpoint" "tune_acme" {
  path                 = "sys/mounts/${vault_mount.pki.path}/tune"
  ignore_absent_fields = true
  disable_delete       = true
  write_fields         = ["passthrough_request_headers", "allowed_response_headers", "audit_non_hmac_request_keys", "audit_non_hmac_response_keys"]
  data_json            = <<EOT
{
  "passthrough_request_headers": [
    "If-Modified-Since"
  ],
  "allowed_response_headers": [
    "Last-Modified", 
    "Location", 
    "Replay-Nonce", 
    "Link"
  ]
}
EOT
}
