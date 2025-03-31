output "root_cert_pem" {
  value = tls_self_signed_cert.root.cert_pem
}

output "int_ca_pem" {
  value = tls_locally_signed_cert.int_ca.cert_pem
}

# https://discuss.hashicorp.com/t/transforming-a-list-of-objects-to-a-map/25373
# output "signed_cert_pem" {
#   sensitive = true
#   # value     = tolist(tls_locally_signed_cert.cert.*)
#   # https://stackoverflow.com/questions/64989080/terraform-modules-output-from-for-each/64992041#64992041
#   value = tomap({
#     for key, value in tls_locally_signed_cert.cert :
#     key => value.cert_pem
#   })
#   # value = tolist([tomap({
#   #   for cert, details in tls_locally_signed_cert.cert :
#   #   cert => details.cert_pem
#   # })])
# }

# output "signed_key" {
#   sensitive = true
#   value = tomap({
#     for key, value in tls_private_key.key :
#     key => value.private_key_pem
#   })
#   # value = tolist(tls_private_key.key.*)
# }

# output "signed_key_pkcs8" {
#   sensitive = true
#   value = tomap({
#     for key, value in tls_private_key.key :
#     key => value.private_key_pem_pkcs8
#   })
#   # value = tolist(tls_private_key.key.*)
# }

output "signed_certs" {
  value = [
    for key in var.certs : {
      name      = key.name
      ca        = tls_locally_signed_cert.int_ca.cert_pem
      cert_pem  = "${tls_locally_signed_cert.cert[key.name].cert_pem}${tls_locally_signed_cert.int_ca.cert_pem}"
      key_pem   = tls_private_key.key[key.name].private_key_pem
      key_pkcs8 = tls_private_key.key[key.name].private_key_pem_pkcs8
    }
  ]
  sensitive = true
}
