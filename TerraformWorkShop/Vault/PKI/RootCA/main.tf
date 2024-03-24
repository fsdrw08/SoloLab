# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
resource "vault_mount" "pki" {
  path                      = "pki/root"
  type                      = "pki"
  description               = "PKI engine hosting root CA v1 for sololab"
  default_lease_ttl_seconds = (60 * 60)                # 1 hour in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

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
# resource "vault_pki_secret_backend_crl_config" "pki" {
#   depends_on = [vault_mount.pki]
#   backend    = vault_mount.pki.path
#   expiry     = "8760h"
#   disable    = false
# }

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki.path
  name             = "RootCA-v1-role"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["infra.sololab", "service.consul"]
  allow_subdomains = true
  allow_any_name   = true
}

# upload root ca cert bundle manually, or uncomment below block
# https://github.com/stvdilln/vault-ca-demo/blob/52d03797168fdff075f638e57362ac8c4946cc94/root_ca.tf#L101
# resource "vault_pki_secret_backend_config_ca" "pki" {

#   depends_on = [vault_mount.pki]
#   backend    = vault_mount.pki.path

#   # pem_bundle = format("%s\n%s", data.terraform_remote_state.pki[0].outputs.root_ca_key,
#   # data.terraform_remote_state.pki[0].outputs.root_ca_crt)

#   pem_bundle = file("${path.module}/../../../TLS/RootCA/RootCA_bundle.pem")
# }


data "vault_pki_secret_backend_issuers" "issuers" {
  backend = vault_mount.pki.path
}

resource "vault_pki_secret_backend_issuer" "issuer" {
  count                          = data.vault_pki_secret_backend_issuers.issuers.key_info == null ? 0 : 1
  backend                        = vault_mount.pki.path
  issuer_ref                     = element(keys(data.vault_pki_secret_backend_issuers.issuers.key_info), 0)
  revocation_signature_algorithm = "SHA256WithRSA"
  issuer_name                    = "RootCA-v1"
}
