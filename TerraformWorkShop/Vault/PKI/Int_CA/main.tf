# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
resource "vault_mount" "pki" {
  path                      = "pki/ica2_v1"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA2 v1 for sololab"
  default_lease_ttl_seconds = (60 * 60 * 24 * 91)      # 91 days in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

# https://www.infralovers.com/blog/2023-10-16-hashicorp-vault-acme-terraform-configuration/
resource "vault_pki_secret_backend_config_cluster" "config_cluster" {
  backend  = vault_mount.pki.path
  path     = "https://${local.VAULT_ADDR}/v1/${vault_mount.pki.path}"
  aia_path = "https://${local.VAULT_ADDR}/v1/${vault_mount.pki.path}"
}

# Enable Authority Information Access (AIA) templating
# Configure the Authority Information Access (AIA)
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca:~:text=The%20vault_pki_secret_backend_config_urls%20configures%20CA%20and%20CRL%20URLs
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls
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
    "{{cluster_path}}/ocsp",
  ]
}

# Certificate Revocation List (CRL)
# resource "vault_pki_secret_backend_crl_config" "pki_root" {
#   depends_on = [vault_mount.pki_root]
#   backend    = vault_mount.pki_root.path
#   expiry     = "8760h"
#   disable    = false
# }

# intermediate CSR
resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate_cert_request" {
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "Sololab Intermediate CA2"

}

data "vault_pki_secret_backend_issuers" "root_issuers" {
  backend = "pki/root"
}

# sign cert by root ca
resource "vault_pki_secret_backend_root_sign_intermediate" "root_sign_intermediate" {
  backend     = "pki/root"
  csr         = vault_pki_secret_backend_intermediate_cert_request.intermediate_cert_request.csr
  common_name = "Sololab Intermediate CA2"
  issuer_ref  = element(keys(data.vault_pki_secret_backend_issuers.root_issuers.key_info), 0)
  ttl         = "26280h" # 3y
}

# import intermediate cert to Vault
resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate_set_signed" {
  backend     = vault_mount.pki.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.root_sign_intermediate.certificate
}

#  for the Intermediate CA, we need to generate a role to consume the PKI secret engine as a client.
# Using the vault_pki_secret_backend_role resource creates a role for this CA; 
# creating this role allows for specifying an issuer when necessary for the purposes of this scenario. 
# This also provides a simple way to transition from one issuer to another by referring to it by name.
resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "IntCA2-v1-role-default"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["infra.sololab", "service.consul"]
  allow_subdomains = true
  allow_any_name   = true
}
