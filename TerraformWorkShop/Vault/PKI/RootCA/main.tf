# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
# https://github.com/hashicorp-education/learn-vault-pki-engine/blob/main/terraform/main.tf
resource "vault_mount" "pki_root" {
  path                      = "pki/root"
  type                      = "pki"
  description               = "PKI engine hosting root CA v1 for sololab"
  default_lease_ttl_seconds = (60 * 60)                # 1 hour in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

# Certificate Revocation List (CRL)
# resource "vault_pki_secret_backend_crl_config" "pki_root" {
#   depends_on = [vault_mount.pki_root]
#   backend    = vault_mount.pki_root.path
#   expiry     = "8760h"
#   disable    = false
# }

# resource "vault_pki_secret_backend_config_urls" "pki_root" {
#   depends_on = [vault_pki_secret_backend_crl_config.pki_root]
#   backend    = vault_mount.pki_root.path

#   # for the url of issuering CA, crl, ocsp, they should connect with http, not https
#   # https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca
#   # e.g. http://vault.infra.sololab/v1/sololab-pki/v1/ica1/v1/crl
#   # ref: https://serverfault.com/questions/1023474/ocsp-setup-for-vault
#   issuing_certificates    = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/ca.crt"]
#   crl_distribution_points = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/crl"]
#   ocsp_servers            = ["http://${local.VAULT_ADDR}/ocsp_root"]
# }

resource "vault_pki_secret_backend_role" "pki_root" {
  backend          = vault_mount.pki_root.path
  name             = "RootCA-v1-role"
  ttl              = 86400
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["infra.sololab", "service.consul"]
  allow_subdomains = true
  allow_any_name   = true
}

# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine#step-1-generate-root-ca:~:text=The%20vault_pki_secret_backend_config_urls%20configures%20CA%20and%20CRL%20URLs
resource "vault_pki_secret_backend_config_urls" "pki_root" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/ca.crt"]
  crl_distribution_points = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/crl"]
  ocsp_servers            = ["http://${local.VAULT_ADDR}/ocsp_root"]
}

# upload root ca cert bundle manually, or uncomment below block
# https://github.com/stvdilln/vault-ca-demo/blob/52d03797168fdff075f638e57362ac8c4946cc94/root_ca.tf#L101
# resource "vault_pki_secret_backend_config_ca" "pki_root" {

#   depends_on = [vault_mount.pki_root]
#   backend    = vault_mount.pki_root.path

#   # pem_bundle = format("%s\n%s", data.terraform_remote_state.pki_root[0].outputs.root_ca_key,
#   # data.terraform_remote_state.pki_root[0].outputs.root_ca_crt)

#   pem_bundle = file("${path.module}/../../../TLS/RootCA/RootCA_bundle.pem")
# }


data "vault_pki_secret_backend_issuers" "pki_root" {
  backend = vault_mount.pki_root.path
}

resource "vault_pki_secret_backend_issuer" "pki_root" {
  count                          = data.vault_pki_secret_backend_issuers.pki_root.key_info == null ? 0 : 1
  backend                        = vault_mount.pki_root.path
  issuer_ref                     = element(keys(data.vault_pki_secret_backend_issuers.pki_root.key_info), 0)
  revocation_signature_algorithm = "SHA256WithRSA"
  issuer_name                    = "RootCA-v1"
}
