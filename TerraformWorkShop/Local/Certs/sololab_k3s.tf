# # https://github.com/tmsmr/tf-ca/blob/d8c2d45bcd1e57f9478f63e8d426668e278e011f/main.tf
# # http://vcloud-lab.com/entries/devops/terraform-for-each-loop-on-resource-example
# variable "k3s_ca_map" {
#   type = map(object({
#     CN = string,
#     FN = string,
#   }))

#   default = {
#     "k3s-client-ca" = {
#       CN = "k3s-client-ca"
#       FN = "client-ca"
#     }
#     "k3s-server-ca" = {
#       CN = "k3s-server-ca"
#       FN = "server-ca"
#     }
#     "k3s-request-header-ca" = {
#       CN = "k3s-request-header-ca"
#       FN = "request-header-ca"
#     }
#   }
# }

# resource "tls_private_key" "sololab_k3s" {
#   for_each = var.k3s_ca_map

#   algorithm = "ED25519"
# }

# resource "tls_cert_request" "sololab_k3s" {
#   for_each = var.k3s_ca_map

#   private_key_pem = tls_private_key.sololab_k3s[each.key].private_key_pem

#   subject {
#     common_name  = each.value["CN"]
#     organization = "Sololab"
#   }
# }

# resource "tls_locally_signed_cert" "sololab_k3s" {
#   for_each = var.k3s_ca_map

#   cert_request_pem = tls_cert_request.sololab_k3s[each.key].cert_request_pem

#   ca_private_key_pem    = tls_private_key.root_ca.private_key_pem
#   ca_cert_pem           = tls_self_signed_cert.root_ca.cert_pem
#   validity_period_hours = (10 * 365 * 24) # 10 years

#   is_ca_certificate = true

#   allowed_uses = [
#     "digital_signature",
#     "key_encipherment",
#     "cert_signing",
#   ]
# }

# resource "local_file" "sololab_k3s_crt" {
#   for_each = var.k3s_ca_map

#   content = format("%s\n%s", tls_locally_signed_cert.sololab_k3s[each.key].cert_pem,
#   tls_self_signed_cert.root_ca.cert_pem)
#   filename = "${path.module}/${each.value["FN"]}.crt"
# }

# resource "local_file" "sololab_k3s_key" {
#   for_each = var.k3s_ca_map

#   content  = tls_private_key.sololab_k3s[each.key].private_key_pem
#   filename = "${path.module}/${each.value["FN"]}.key"
# }

