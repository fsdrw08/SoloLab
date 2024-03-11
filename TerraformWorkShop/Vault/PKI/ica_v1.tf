resource "vault_mount" "pki_ica_v1" {
  path                      = "pki/ica1_v1"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA1 v1 for sololab org"
  default_lease_ttl_seconds = (60 * 60)                # 1 hour in seconds
  max_lease_ttl_seconds     = (3 * 365 * 24 * 60 * 60) # 3 years in seconds
}

resource "vault_pki_secret_backend_crl_config" "pki_ica_v1" {
  depends_on = [vault_mount.pki_ica_v1]
  backend    = vault_mount.pki_ica_v1.path
  expiry     = "8760h"
  disable    = false
}

resource "vault_pki_secret_backend_config_urls" "pki_ica_v1" {
  depends_on = [vault_pki_secret_backend_crl_config.pki_ica_v1]
  backend    = vault_mount.pki_ica_v1.path

  # for the url of issuering CA, crl, ocsp, they should connect with http, not https
  # e.g. http://vault.infra.sololab/v1/sololab-pki/v1/ica1/v1/crl
  # ref: https://serverfault.com/questions/1023474/ocsp-setup-for-vault
  issuing_certificates    = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_ica_v1.path}/ca.crt"]
  crl_distribution_points = ["http://${local.VAULT_ADDR}/v1/${vault_mount.pki_ica_v1.path}/crl"]
  ocsp_servers            = ["http://${local.VAULT_ADDR}/ocsp_int1"]
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_ica_v1" {
  depends_on   = [vault_mount.pki_ica_v1]
  backend      = vault_mount.pki_ica_v1.path
  type         = "internal"
  common_name  = "Sololab Intermediate CA1 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  organization = "Sololab"
  country      = "CN"
  locality     = "Foshan"
  province     = "GD"
}

# data "terraform_remote_state" "root_ca" {
#   backend = "local"

#   config = {
#     path = "${path.module}/../../Local/Certs/terraform.tfstate"
#   }
# }

# resource "tls_locally_signed_cert" "pki_ica_v1" {
#   depends_on = [
#     vault_pki_secret_backend_intermediate_cert_request.pki_ica_v1,
#     data.terraform_remote_state.root_ca,
#   ]

#   cert_request_pem   = vault_pki_secret_backend_intermediate_cert_request.pki_ica_v1.csr
#   ca_private_key_pem = data.terraform_remote_state.root_ca.outputs.root_ca_key
#   ca_cert_pem        = data.terraform_remote_state.root_ca.outputs.root_ca_crt

#   validity_period_hours = (10 * 365 * 24) + (2 * 24) # 10 years
#   is_ca_certificate     = true
#   set_subject_key_id    = true
#   allowed_uses = [
#     "any_extended",
#     "cert_signing",
#     "client_auth",
#     "code_signing",
#     "content_commitment",
#     "crl_signing",
#     "data_encipherment",
#     "decipher_only",
#     "digital_signature",
#     "email_protection",
#     "encipher_only",
#     "ipsec_end_system",
#     "ipsec_tunnel",
#     "ipsec_user",
#     "key_agreement",
#     "key_encipherment",
#     "microsoft_commercial_code_signing",
#     "microsoft_kernel_code_signing",
#     "microsoft_server_gated_crypto",
#     "netscape_server_gated_crypto",
#     "ocsp_signing",
#     "server_auth",
#     "timestamping"
#   ]
# }

resource "vault_pki_secret_backend_root_sign_intermediate" "pki_ica_v1" {
  depends_on = [
    vault_mount.pki_root,
    vault_pki_secret_backend_intermediate_cert_request.pki_ica_v1,
  ]
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.pki_ica_v1.csr
  common_name          = "Intermediate CA1 v1.1"
  exclude_cn_from_sans = true
  organization         = "Sololab"
  country              = "CN"
  locality             = "Foshan"
  province             = "GD"
  max_path_length      = 0
  ttl                  = (10 * 365 * 24 * 3600) + (2 * 24 * 3600) # 10 years in second
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_ica_v1" {
  depends_on = [vault_mount.pki_ica_v1]
  backend    = vault_mount.pki_ica_v1.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.pki_ica_v1.certificate_bundle
}


resource "vault_pki_secret_backend_role" "pki_ica_v1" {
  backend  = vault_mount.pki_ica_v1.path
  name     = "pki_ica_v1"
  ttl      = (365 * 24 * 3600) # 1 year in second
  key_type = "rsa"
  key_bits = 2048
  # https://github.com/thomas-maurice/sample-home-vault/blob/b5c61e528b62cfdda2092e820eaa3d15d7226368/pki.tf
  key_usage = [
    "DigitalSignature",
    "KeyAgreement",
    "KeyEncipherment",
  ]
  allow_any_name     = false
  allow_localhost    = false
  allowed_domains    = ["sololab"]
  allow_bare_domains = false
  allow_subdomains   = true
  country            = ["CN"]
  locality           = ["Foshan"]
  province           = ["GD"]
}
