# https://github.com/livioribeiro/nomad-lxd-terraform/blob/c396cebc1c08a0cca977ee9ceaa6dde8f0ae7c8a/vault_pki.tf#L8
# https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine-external-ca
resource "vault_mount" "pki_root" {
  path                      = "pki/root"
  type                      = "pki"
  description               = "PKI engine hosting root CA v1 for sololab"
  default_lease_ttl_seconds = (60 * 60)                # 1 hour in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

# Certificate Revocation List (CRL)
resource "vault_pki_secret_backend_crl_config" "pki_root" {
  depends_on = [vault_mount.pki_root]
  backend    = vault_mount.pki_root.path
  expiry     = "8760h"
  disable    = false
}

resource "vault_pki_secret_backend_config_urls" "pki_root" {
  depends_on = [vault_pki_secret_backend_crl_config.pki_root]
  backend    = vault_mount.pki_root.path

  # for the url of issuering CA, crl, ocsp, they should connect with http, not https
  # e.g. http://vault.infra.sololab/v1/sololab-pki/v1/ica1/v1/crl
  # ref: https://serverfault.com/questions/1023474/ocsp-setup-for-vault
  issuing_certificates    = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/ca.crt"]
  crl_distribution_points = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_root.path}/crl"]
  ocsp_servers            = ["http://${local.VAULT_ADDR}/ocsp_root"]
}

variable "load_root_ca_bool" {
  type = bool
}

data "terraform_remote_state" "pki_root" {
  count   = var.load_root_ca_bool ? 1 : 0
  backend = "local"
  config = {
    path = "${path.module}/../../Local/Certs/terraform.tfstate"
  }
}

# https://github.com/stvdilln/vault-ca-demo/blob/52d03797168fdff075f638e57362ac8c4946cc94/root_ca.tf#L101
resource "vault_pki_secret_backend_config_ca" "pki_root" {
  count = var.load_root_ca_bool ? 1 : 0

  depends_on = [vault_mount.pki_root]
  backend    = vault_mount.pki_root.path

  pem_bundle = format("%s\n%s", data.terraform_remote_state.pki_root[0].outputs.root_ca_key,
  data.terraform_remote_state.pki_root[0].outputs.root_ca_crt)
}
