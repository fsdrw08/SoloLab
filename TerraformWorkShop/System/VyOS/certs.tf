data "terraform_remote_state" "root_ca" {
  backend = "local"
  config = {
    path = "../../RootCA/terraform.tfstate"
  }
}

data "system_command" "ca_dir" {
  command = "if [ ! -d ${var.root_ca.dir} ]; then mkdir -p ${var.root_ca.dir}; fi"
}

resource "system_file" "root_ca" {
  depends_on = [data.system_command.ca_dir]
  path       = format("%s/%s", var.root_ca.dir, "ca.pem")
  # content    = tls_self_signed_cert.root.cert_pem
  content = data.terraform_remote_state.root_ca.outputs.root_cert_pem
}

# output "test" {
#   value = data.terraform_remote_state.root_ca.outputs.signed_cert_pem["vault"].ca_private_key_pem
# }

# resource "tls_private_key" "key" {
#   for_each  = var.certs
#   algorithm = each.value.key.algorithm
#   rsa_bits  = each.value.key.rsa_bits
# }

# resource "tls_cert_request" "csr" {
#   for_each        = var.certs
#   private_key_pem = tls_private_key.key[each.key].private_key_pem

#   dns_names = each.value.cert.dns_names

#   subject {
#     common_name         = lookup(each.value.cert.subject, "common_name", null)
#     country             = lookup(each.value.cert.subject, "country", null)
#     locality            = lookup(each.value.cert.subject, "locality", null)
#     organization        = lookup(each.value.cert.subject, "organization", null)
#     organizational_unit = lookup(each.value.cert.subject, "organizational_unit", null)
#     postal_code         = lookup(each.value.cert.subject, "postal_code", null)
#     province            = lookup(each.value.cert.subject, "province", null)
#     serial_number       = lookup(each.value.cert.subject, "serial_number", null)
#     street_address      = lookup(each.value.cert.subject, "street_address", null)
#   }
# }

# resource "tls_locally_signed_cert" "cert" {
#   for_each           = var.certs
#   cert_request_pem   = tls_cert_request.csr[each.key].cert_request_pem
#   ca_private_key_pem = tls_private_key.root.private_key_pem
#   ca_cert_pem        = tls_self_signed_cert.root.cert_pem

#   validity_period_hours = each.value.cert.validity_period_hours

#   allowed_uses = each.value.cert.allowed_uses
# }

resource "system_file" "cert" {
  for_each = {
    for cert in var.certs : cert.name => cert
  }
  path = format("%s/%s", each.value.dir, "${each.value.name}.pem")
  # content = format("%s\n%s", tls_locally_signed_cert.cert[each.key].cert_pem,
  # tls_self_signed_cert.root.cert_pem)
  # content = format("%s\n%s", data.terraform_remote_state.signed_cert_pem[each.key].cert_pem,
  # data.terraform_remote_state.root_ca.outputs.root_cert_pem)
  # content = data.terraform_remote_state.root_ca.outputs.signed_cert_pem[each.key]
  # https://discuss.hashicorp.com/t/transforming-a-list-of-objects-to-a-map/25373
  # content = lookup((merge(data.terraform_remote_state.root_ca.outputs.signed_cert_pem...)), each.key, null) #.cert_pem
  content = lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), each.key, null) #.cert_pem
}


# https://discuss.hashicorp.com/t/transforming-a-list-of-objects-to-a-map/25373
# output "test" {
#   # value = tomap(data.terraform_remote_state.root_ca.outputs.signed_cert_pem)
#   value = merge(data.terraform_remote_state.root_ca.outputs.signed_cert_pem...)
# }

resource "system_file" "key" {
  for_each = {
    for cert in var.certs : cert.name => cert
  }
  path    = format("%s/%s", each.value.dir, "${each.value.name}.key")
  content = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), each.key, null)
}
