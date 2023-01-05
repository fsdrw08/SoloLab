resource "tls_cert_request" "sololab_vault" {
  private_key_pem = tls_private_key.root_ca.private_key_pem

  dns_names = [ 
    "vault.infra.sololab",
    "vault",
  ]
  
  subject {
    common_name  = "vault.infra.sololab"
    organization = "Sololab"
  }
}

resource "tls_locally_signed_cert" "sololab_vault" {
  cert_request_pem   = tls_cert_request.sololab_vault.cert_request_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem

  validity_period_hours = (5 * 365 * 24) # 5 years

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "sololab_vault_crt" {
  content = format("%s\n%s", tls_locally_signed_cert.sololab_vault.cert_pem,
  tls_self_signed_cert.root_ca.cert_pem)
  filename = "${path.module}/../../../HelmWorkShop/vault/sololab_vault.crt"
}

resource "local_file" "sololab_vault_key" {
  content  = tls_cert_request.sololab_vault.private_key_pem
  filename = "${path.module}/../../../HelmWorkShop/vault/sololab_vault.key"
}
