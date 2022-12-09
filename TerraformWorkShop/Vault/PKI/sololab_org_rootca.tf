resource "tls_private_key" "root_ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "root_ca" {
  depends_on = [
    tls_private_key.root_ca
  ]
  
  private_key_pem = tls_private_key.root_ca.private_key_pem

  subject {
    common_name         = "Sololab Root CA"
    organization        = "Sololab Root CA"
    organizational_unit = "Sololab"
    locality            = "Foshan"
    province            = "GD"
    country             = "CN"
  }

  is_ca_certificate = true
  // valid for 10 years
  validity_period_hours = (365 * 24 * 10) # 10 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "key_encipherment",
    "digital_signature",
  ]
}
