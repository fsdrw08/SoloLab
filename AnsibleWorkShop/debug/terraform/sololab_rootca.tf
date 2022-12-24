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
    organization        = "Sololab"
    locality            = "Foshan"
    province            = "GD"
    country             = "CN"
  }

  is_ca_certificate = true
  // valid for 10 years
  validity_period_hours = (365 * 24 * 20)+(24 * 4) # 20 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "local_file" "root_ca" {
  content = tls_self_signed_cert.root_ca.cert_pem
  # content = tls_locally_signed_cert.vault.cert_pem
  filename = "${path.module}/root_ca.crt"
}

# https://developer.hashicorp.com/terraform/language/values/outputs#output-values
output "root_ca_crt" {
  value     = tls_self_signed_cert.root_ca.cert_pem
  sensitive = false
}

output "root_ca_key" {
  value     = tls_self_signed_cert.root_ca.private_key_pem
  sensitive = true
}
