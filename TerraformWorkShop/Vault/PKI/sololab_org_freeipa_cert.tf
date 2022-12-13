resource "vault_pki_secret_backend_cert" "FreeIPA" {
  depends_on = [vault_pki_secret_backend_role.sololab]

  backend = vault_mount.sololab_org_v1_ica2_v1.path
  name = vault_pki_secret_backend_role.sololab.name

  common_name = "infrasvc-fedora37.sololab"
}

# https://access.redhat.com/solutions/2039553
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/installing_identity_management/installing-an-ipa-server-without-a-ca_installing-identity-management
resource "local_file" "CA_chain" {
  content = vault_pki_secret_backend_cert.FreeIPA.ca_chain
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/CA_chain.crt"
}

resource "local_file" "FreeIPA_cert" {
  content = vault_pki_secret_backend_cert.FreeIPA.certificate
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/FreeIPA.crt"
}

resource "local_file" "FreeIPA_key" {
  content = vault_pki_secret_backend_cert.FreeIPA.private_key
  filename = "${path.module}/../../../KubeWorkShop/FreeIPA/data/FreeIPA.key"
}