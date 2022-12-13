resource "vault_mount" "sololab_org_v1_ica1_v1" {
  path                      = "sololab-org/v1/ica1/v1"
  type                      = "pki"
  description               = "PKI engine hosting intermediate CA1 v1 for sololab org"
  default_lease_ttl_seconds = local.default_1hr_in_sec
  max_lease_ttl_seconds     = local.default_3y_in_sec
}

resource "vault_pki_secret_backend_intermediate_cert_request" "sololab_org_v1_ica1_v1" {
  depends_on   = [vault_mount.sololab_org_v1_ica1_v1]
  backend      = vault_mount.sololab_org_v1_ica1_v1.path
  type         = "internal"
  common_name  = "Intermediate CA1 v1"
  key_type     = "rsa"
  key_bits     = "2048"
  ou           = "Sololab org"
  organization = "Sololab"
  country      = "CN"
  locality     = "Foshan"
  province     = "GD"
}

resource "tls_locally_signed_cert" "sololab_org_v1_ica1_v1" {
  depends_on = [
    vault_pki_secret_backend_intermediate_cert_request.sololab_org_v1_ica1_v1,
    tls_self_signed_cert.root_ca
  ]

  cert_request_pem   = vault_pki_secret_backend_intermediate_cert_request.sololab_org_v1_ica1_v1.csr
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = (365 * 24 * 5) # 5 years
  is_ca_certificate     = true
  set_subject_key_id    = true
  allowed_uses = [
    "any_extended",
    "cert_signing",
    "client_auth",
    "code_signing",
    "content_commitment",
    "crl_signing",
    "data_encipherment",
    "decipher_only",
    "digital_signature",
    "email_protection",
    "encipher_only",
    "ipsec_end_system",
    "ipsec_tunnel",
    "ipsec_user",
    "key_agreement",
    "key_encipherment",
    "microsoft_commercial_code_signing",
    "microsoft_kernel_code_signing",
    "microsoft_server_gated_crypto",
    "netscape_server_gated_crypto",
    "ocsp_signing",
    "server_auth",
    "timestamping"
  ]
}

resource "vault_pki_secret_backend_intermediate_set_signed" "sololab_org_v1_ica1_v1_signed_cert" {
  depends_on = [vault_mount.sololab_org_v1_ica1_v1]
  backend    = vault_mount.sololab_org_v1_ica1_v1.path

  certificate = format("%s\n%s", tls_locally_signed_cert.sololab_org_v1_ica1_v1.cert_pem,
    tls_self_signed_cert.root_ca.cert_pem)
}
