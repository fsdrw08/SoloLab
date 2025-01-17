# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
# https://developer.hashicorp.com/vault/docs/secrets/pki/setup#setup
resource "vault_mount" "pki" {
  # the "pki" prefix is the default mount path prefix for mount type of pki
  path                      = var.vault_pki.mount.path
  type                      = "pki"
  description               = var.vault_pki.mount.description
  default_lease_ttl_seconds = (var.vault_pki.mount.default_lease_ttl_years * 365 * 24 * 60 * 60) # 1 year in seconds
  max_lease_ttl_seconds     = (var.vault_pki.mount.max_lease_ttl_years * 365 * 24 * 60 * 60)     # 3 years in seconds
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


# intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_cert_request" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Sololab Intermediate CA2"

}

data "vault_pki_secret_backend_issuers" "root_ca" {
  backend = "pki/root"
}

# sign cert by root ca
resource "vault_pki_secret_backend_root_sign_intermediate" "root_sign_intermediate" {
  backend     = "pki/root"
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_cert_request.csr
  common_name = "Sololab Intermediate CA2"
  issuer_ref  = element(keys(data.vault_pki_secret_backend_issuers.root_ca.key_info), 0)
  ttl         = "26280h" # 3y
}

# import intermediate cert to Vault
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_set_signed" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate.certificate
}

resource "vault_pki_secret_backend_issuer" "issuer" {
  backend                        = vault_mount.pki.path
  issuer_ref                     = vault_pki_secret_backend_intermediate_set_signed.intermediate_set_signed.imported_issuers[0]
  revocation_signature_algorithm = var.vault_pki.issuer.revocation_signature_algorithm
  issuer_name                    = var.vault_pki.issuer.name
}


#  for the Intermediate CA, we need to generate a role to consume the PKI secret engine as a client.
# Using the vault_pki_secret_backend_role resource creates a role for this CA; 
# creating this role allows for specifying an issuer when necessary for the purposes of this scenario. 
# This also provides a simple way to transition from one issuer to another by referring to it by name.
# resource "vault_pki_secret_backend_role" "role" {
#   backend          = vault_mount.pki.path
#   name             = "IntCA2-v1-role-default"
#   ttl              = 86400
#   allow_ip_sans    = true
#   key_type         = "rsa"
#   key_bits         = 4096
#   allowed_domains  = ["infra.sololab", "service.consul"]
#   allow_subdomains = true
#   allow_any_name   = true
# }
