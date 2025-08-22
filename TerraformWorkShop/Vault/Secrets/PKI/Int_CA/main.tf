# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
# https://developer.hashicorp.com/vault/docs/secrets/pki/setup#setup
resource "vault_mount" "pki" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
  }
  # the "pki" prefix is the default mount path prefix for mount type of pki
  path                      = each.value.secret_engine.path
  type                      = "pki"
  description               = each.value.secret_engine.description
  default_lease_ttl_seconds = (each.value.secret_engine.default_lease_ttl_years * 365 * 24 * 60 * 60)
  max_lease_ttl_seconds     = (each.value.secret_engine.max_lease_ttl_years * 365 * 24 * 60 * 60)
}

# intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_cert_request" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.csr != null
  }
  backend     = vault_mount.pki[each.key].path
  type        = "internal"
  common_name = each.value.csr.common_name
}

# get root ca info
data "vault_pki_secret_backend_issuers" "root_ca" {
  count   = var.root_ca_ref.internal == null ? 0 : 1
  backend = var.root_ca_ref.internal.backend
}

# sign cert by root ca
resource "vault_pki_secret_backend_root_sign_intermediate" "root_sign_intermediate" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.csr != null
  }
  backend     = var.root_ca_ref.internal.backend
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_cert_request[each.key].csr
  common_name = each.value.csr.common_name
  issuer_ref  = element(keys(data.vault_pki_secret_backend_issuers.root_ca[0].key_info), 0)
  ttl         = (each.value.csr.ttl_years * 365 * 24 * 60 * 60) # years in seconds
}

# import signed intermediate cert to this secret backend
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_set_signed" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.csr != null
  }
  backend     = vault_mount.pki[each.key].path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate[each.key].certificate
}

# issuer = key pair of public key (the cert) + private key, 
# with this pair, we can issue(sign) certs
resource "vault_pki_secret_backend_issuer" "issuer" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.issuer != null
  }
  backend                        = vault_mount.pki[each.key].path
  issuer_ref                     = vault_pki_secret_backend_intermediate_set_signed.intermediate_set_signed[each.key].imported_issuers[0]
  issuer_name                    = each.value.issuer.name
  revocation_signature_algorithm = each.value.issuer.revocation_signature_algorithm
}

# set issuer above as default issuer
resource "vault_pki_secret_backend_config_issuers" "issuer" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.issuer != null
  }
  backend                       = vault_mount.pki[each.key].path
  default                       = vault_pki_secret_backend_issuer.issuer[each.key].issuer_id
  default_follows_latest_issuer = true
}

# Allows setting the cluster-local's API mount path and AIA distribution point on a particular performance replication cluster.
resource "vault_pki_secret_backend_config_cluster" "config_cluster" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.public_fqdn != null
  }
  backend  = vault_mount.pki[each.key].path
  path     = "https://${each.value.public_fqdn}/v1/${vault_mount.pki[each.key].path}"
  aia_path = "https://${each.value.public_fqdn}/v1/${vault_mount.pki[each.key].path}"
}

# Enable Authority Information Access (AIA) templating
# Configure the Authority Information Access (AIA)
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca:~:text=The%20vault_pki_secret_backend_config_urls%20configures%20CA%20and%20CRL%20URLs
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls
# https://serverfault.com/questions/1023474/ocsp-setup-for-vault/1159997#1159997
# https://developer.hashicorp.com/vault/api-docs/secret/pki#ocsp-request
resource "vault_pki_secret_backend_config_urls" "config_urls" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.enable_backend_config == true
  }
  backend           = vault_mount.pki[each.key].path
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
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.enable_backend_config == true
  }
  backend      = vault_mount.pki[each.key].path
  expiry       = "72h"
  disable      = false
  auto_rebuild = true
  enable_delta = true
}

locals {
  roles = flatten([
    for ca in var.intermediate_cas : [
      for role in ca.roles : {
        path   = ca.secret_engine.path
        config = role
      }
    ]
    if ca.roles != null
  ])
}

#  for the Intermediate CA, we need to generate a role to consume the PKI secret engine as a client.
# Using the vault_pki_secret_backend_role resource creates a role for this CA; 
# creating this role allows for specifying an issuer when necessary for the purposes of this scenario. 
# This also provides a simple way to transition from one issuer to another by referring to it by name.
resource "vault_pki_secret_backend_role" "role" {
  for_each = {
    for role in local.roles : role.config.name => role
  }
  backend = vault_mount.pki[each.value.path].path
  name    = each.value.config.name
  # https://developer.hashicorp.com/vault/api-docs/secret/pki#ext_key_usage
  # https://pkg.go.dev/crypto/x509#ExtKeyUsage
  ext_key_usage    = each.value.config.ext_key_usage
  ttl              = (each.value.config.ttl_months * 60 * 60 * 24 * 31)
  allow_ip_sans    = each.value.config.allow_ip_sans
  key_type         = each.value.config.key_type
  key_bits         = each.value.config.key_bits
  allowed_domains  = each.value.config.allowed_domains
  allow_subdomains = each.value.config.allow_subdomains
  allow_any_name   = each.value.config.allow_any_name
}

# acme

# enable the acme configuration.
# https://www.infralovers.com/blog/2023-10-16-hashicorp-vault-acme-terraform-configuration/#:~:text=apply%20the%20secrets,1
#
# 202501: consider use vault_pki_secret_backend_config_acme instead 
# ref: https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#acme-certificate-issuance
# https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#set-acme-configuration
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_acme
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_acme
resource "vault_pki_secret_backend_config_acme" "config_acme" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.acme_allowed_roles != null
  }
  backend       = vault_mount.pki[each.key].path
  enabled       = true
  allowed_roles = each.value.acme_allowed_roles
}

# apply the secrets engine tuning parameter
# ref: https://developer.hashicorp.com/vault/api-docs/secret/pki#acme-required-headers
# https://developer.hashicorp.com/vault/api-docs/secret/pki/issuance#acme-required-headers
resource "vault_generic_endpoint" "tune_acme" {
  for_each = {
    for ca in var.intermediate_cas : ca.secret_engine.path => ca
    if ca.acme_allowed_roles != null
  }
  path                 = "sys/mounts/${vault_mount.pki[each.key].path}/tune"
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
