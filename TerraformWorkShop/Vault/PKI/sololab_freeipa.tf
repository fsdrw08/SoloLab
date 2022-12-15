# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_cert
resource "vault_pki_secret_backend_cert" "FreeIPA" {
  # depends_on  = [vault_pki_secret_backend_role.sololab_v1_ica2_v1]
  # backend     = vault_mount.sololab_v1_ica2_v1.path
  # name        = vault_pki_secret_backend_role.sololab_v1_ica2_v1.name

  depends_on  = [vault_pki_secret_backend_role.sololab_int1_v1]
  backend     = vault_mount.sololab_int1_v1.path
  name        = vault_pki_secret_backend_role.sololab_int1_v1.name
  common_name = "ipa.infra.sololab"
  alt_names = [
    "ipa.infra.sololab",
  ]
}

# https://access.redhat.com/solutions/2039553
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/installing_identity_management/installing-an-ipa-server-without-a-ca_installing-identity-management
resource "local_file" "CA_chain" {
  content  = vault_pki_secret_backend_cert.FreeIPA.ca_chain
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/CA_chain.crt"
}

resource "local_file" "FreeIPA_cert" {
  content  = vault_pki_secret_backend_cert.FreeIPA.certificate
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/sololab_freeipa.crt"
}

resource "local_file" "FreeIPA_key" {
  content  = vault_pki_secret_backend_cert.FreeIPA.private_key
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/sololab_freeipa.key"
}
