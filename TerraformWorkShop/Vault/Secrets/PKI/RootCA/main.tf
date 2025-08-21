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

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = var.vault_pki.role.name
  ttl              = (var.vault_pki.role.ttl_years * 365 * 24 * 60 * 60) # years in seconds
  allow_ip_sans    = var.vault_pki.role.allow_ip_sans
  key_type         = var.vault_pki.role.key_type
  key_bits         = var.vault_pki.role.key_bits
  allowed_domains  = var.vault_pki.role.allowed_domains
  allow_subdomains = var.vault_pki.role.allow_subdomains
  allow_any_name   = var.vault_pki.role.allow_any_name
}

# this resource is used to upload root cacert bundle, after specify root_ca_bundle_path and apply
# we can set root_ca_bundle_path to empty("") to delete this resource
# https://github.com/stvdilln/vault-ca-demo/blob/52d03797168fdff075f638e57362ac8c4946cc94/root_ca.tf#L101
resource "vault_pki_secret_backend_config_ca" "config_ca" {
  count = var.vault_pki.ca.external_import.ref_cert_bundle_path == "" ? 0 : 1

  depends_on = [vault_mount.pki]
  backend    = vault_mount.pki.path

  pem_bundle = file("${path.module}/${var.vault_pki.ca.external_import.ref_cert_bundle_path}")
}

data "vault_pki_secret_backend_issuers" "issuers" {
  depends_on = [vault_pki_secret_backend_config_ca.config_ca]
  backend    = vault_mount.pki.path
}

# issuer means the pair of public key (the cert) + private key, 
# with this pair, we can issue(sign) certs
# https://developer.hashicorp.com/vault/api-docs/secret/pki#notice-about-new-multi-issuer-functionality
# Vault since 1.11.0 allows a single PKI mount to have multiple Certificate Authority (CA) certificates ("issuers") in a single mount, 
# for the purpose of facilitating rotation.
resource "vault_pki_secret_backend_issuer" "issuer" {
  depends_on                     = [data.vault_pki_secret_backend_issuers.issuers]
  backend                        = vault_mount.pki.path
  issuer_ref                     = element(keys(data.vault_pki_secret_backend_issuers.issuers.key_info), 0)
  revocation_signature_algorithm = var.vault_pki.issuer.revocation_signature_algorithm
  issuer_name                    = var.vault_pki.issuer.name
}
