resource "vault_mount" "sololab_root_v1" {
  path                      = "sololab-pki/root_v1"
  type                      = "pki"
  description               = "PKI engine hosting root CA v1 for sololab"
  default_lease_ttl_seconds = (60 * 60)                # 1 hour in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

resource "vault_pki_secret_backend_crl_config" "sololab_root_v1" {
  depends_on = [vault_mount.sololab_root_v1]
  backend    = vault_mount.sololab_root_v1.path
  expiry     = "8760h"
  disable    = false
}

resource "vault_pki_secret_backend_config_urls" "sololab_root_v1" {
  depends_on = [vault_pki_secret_backend_crl_config.sololab_root_v1]
  backend    = vault_mount.sololab_root_v1.path

  # for the url of issuering CA, crl, ocsp, they should connect with http, not https
  # e.g. http://vault.infra.sololab/v1/sololab-pki/v1/ica1/v1/crl
  # ref: https://serverfault.com/questions/1023474/ocsp-setup-for-vault
  issuing_certificates    = ["http://${local.VAULT_ADDR}/v1/${vault_mount.sololab_root_v1.path}/ca.crt"]
  crl_distribution_points = ["http://${local.VAULT_ADDR}/v1/${vault_mount.sololab_root_v1.path}/crl"]
  ocsp_servers            = ["http://${local.VAULT_ADDR}/ocsp_root"]
}

variable "load_root_ca_bool" {
  type = bool
}

data "terraform_remote_state" "sololab_root_v1" {
  count   = var.load_root_ca_bool ? 1 : 0
  backend = "local"
  config = {
    path = "${path.module}/../../Local/Certs/terraform.tfstate"
  }
}

resource "vault_pki_secret_backend_config_ca" "sololab_root_v1" {
  count = var.load_root_ca_bool ? 1 : 0

  depends_on = [vault_mount.sololab_root_v1]
  backend    = vault_mount.sololab_root_v1.path

  pem_bundle = format("%s\n%s", data.terraform_remote_state.sololab_root_v1[0].outputs.root_ca_key,
  data.terraform_remote_state.sololab_root_v1[0].outputs.root_ca_crt)
}
