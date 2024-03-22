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
  validity_period_hours = var.root_ca.cert.validity_period_hours

  allowed_uses = var.root_ca.cert.allowed_uses
}

resource "local_file" "root" {
  content  = tls_self_signed_cert.root.cert_pem
  filename = "${path.root}/root.crt"
}

# resource "local_file" "rootca_pem_bundle" {
#   content = join("", [
#     tls_private_key.root.private_key_pem,
#     tls_self_signed_cert.root.cert_pem
#   ])
#   filename = "${path.root}/RootCA_bundle.pem"
# }

# resource "local_file" "intca_pem_bundle" {
#   content = join("", [
#     tls_private_key.int_ca.private_key_pem,
#     tls_locally_signed_cert.int_ca.cert_pem
#   ])
#   filename = "${path.root}/IntCA_bundle.pem"
# }

resource "tls_private_key" "int_ca" {
  algorithm = var.int_ca.key.algorithm
  rsa_bits  = var.int_ca.key.rsa_bits
}

resource "tls_cert_request" "int_ca" {
  private_key_pem = tls_private_key.int_ca.private_key_pem

  subject {
    common_name         = lookup(var.int_ca.cert.subject, "common_name", null)
    country             = lookup(var.int_ca.cert.subject, "country", null)
    locality            = lookup(var.int_ca.cert.subject, "locality", null)
    organization        = lookup(var.int_ca.cert.subject, "organization", null)
    organizational_unit = lookup(var.int_ca.cert.subject, "organizational_unit", null)
    postal_code         = lookup(var.int_ca.cert.subject, "postal_code", null)
    province            = lookup(var.int_ca.cert.subject, "province", null)
    serial_number       = lookup(var.int_ca.cert.subject, "serial_number", null)
    # street_address      = lookup(each.value.cert.subject, "street_address", null)
  }
}

resource "tls_locally_signed_cert" "int_ca" {
  cert_request_pem   = tls_cert_request.int_ca.cert_request_pem
  ca_private_key_pem = tls_private_key.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  is_ca_certificate     = true
  validity_period_hours = var.int_ca.cert.validity_period_hours

  allowed_uses = var.int_ca.cert.allowed_uses
}

resource "tls_private_key" "key" {
  for_each = {
    for cert in var.certs : cert.name => cert
  }
  algorithm = each.value.key.algorithm
  rsa_bits  = each.value.key.rsa_bits
}

resource "tls_cert_request" "csr" {
  for_each = {
    for cert in var.certs : cert.name => cert
  }
  private_key_pem = tls_private_key.key[each.key].private_key_pem

  ip_addresses = each.value.cert.ip_addresses
  dns_names    = each.value.cert.dns_names

  subject {
    common_name         = lookup(each.value.cert.subject, "common_name", null)
    country             = lookup(each.value.cert.subject, "country", null)
    locality            = lookup(each.value.cert.subject, "locality", null)
    organization        = lookup(each.value.cert.subject, "organization", null)
    organizational_unit = lookup(each.value.cert.subject, "organizational_unit", null)
    postal_code         = lookup(each.value.cert.subject, "postal_code", null)
    province            = lookup(each.value.cert.subject, "province", null)
    serial_number       = lookup(each.value.cert.subject, "serial_number", null)
    # street_address      = lookup(each.value.cert.subject, "street_address", null)
  }
}

resource "tls_locally_signed_cert" "cert" {
  for_each = {
    for cert in var.certs : cert.name => cert
  }
  cert_request_pem = tls_cert_request.csr[each.key].cert_request_pem
  # ca_private_key_pem = tls_private_key.root.private_key_pem
  # ca_cert_pem        = tls_self_signed_cert.root.cert_pem
  ca_private_key_pem = tls_private_key.int_ca.private_key_pem
  ca_cert_pem        = tls_locally_signed_cert.int_ca.cert_pem

  validity_period_hours = each.value.cert.validity_period_hours

  allowed_uses = each.value.cert.allowed_uses
}
