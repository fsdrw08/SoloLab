resource "tls_private_key" "root" {
  algorithm = var.root_ca.key.algorithm
  rsa_bits  = var.root_ca.key.rsa_bits
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name         = lookup(var.root_ca.cert.subject, "common_name", null)
    country             = lookup(var.root_ca.cert.subject, "country", null)
    locality            = lookup(var.root_ca.cert.subject, "locality", null)
    organization        = lookup(var.root_ca.cert.subject, "organization", null)
    organizational_unit = lookup(var.root_ca.cert.subject, "organizational_unit", null)
    postal_code         = lookup(var.root_ca.cert.subject, "postal_code", null)
    province            = lookup(var.root_ca.cert.subject, "province", null)
    serial_number       = lookup(var.root_ca.cert.subject, "serial_number", null)
    street_address      = lookup(var.root_ca.cert.subject, "street_address", null)
  }

  is_ca_certificate = true
  // valid for 10 years
  validity_period_hours = (365 * 24 * 20) + (24 * 4) # 20 years

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

data "system_command" "ca_dir" {
  command = "if [ ! -d ${var.ca.dir} ]; then mkdir -p ${var.ca.dir}; fi"
}

resource "system_file" "root_ca" {
  depends_on = [data.system_command.ca_dir]
  path       = var.ca.dir
  content    = tls_self_signed_cert.root.cert_pem
}

