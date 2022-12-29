# # # https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_cert
# resource "vault_pki_secret_backend_cert" "ldap" {
#   depends_on  = [vault_pki_secret_backend_role.sololab_int1_v1]
#   backend     = vault_mount.sololab_int1_v1.path
#   name        = vault_pki_secret_backend_role.sololab_int1_v1.name
#   common_name = "ldap.infra.sololab"
#   alt_names = [
#     "ldap.infra.sololab",
#   ]
# }

# # https://access.redhat.com/solutions/2039553
# # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/installing_identity_management/installing-an-ipa-server-without-a-ca_installing-identity-management
# resource "local_file" "CA_chain" {
#   content  = vault_pki_secret_backend_cert.ldap.ca_chain
#   filename = "${path.module}/../../../KubeWorkShop/openldap/certs/CA_chain.crt"
# }

# resource "local_file" "ldap_cert" {
#   content  = vault_pki_secret_backend_cert.ldap.certificate
#   filename = "${path.module}/../../../KubeWorkShop/openldap/certs/sololab_ldap.crt"
# }

# resource "local_file" "ldap_key" {
#   content  = vault_pki_secret_backend_cert.ldap.private_key
#   filename = "${path.module}/../../../KubeWorkShop/openldap/certs/sololab_ldap.key"
# }
