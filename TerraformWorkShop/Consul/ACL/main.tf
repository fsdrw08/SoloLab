resource "consul_acl_policy" "policy" {
  for_each = {
    for policy in var.policies : policy.name => policy
  }
  name        = each.value.name
  description = each.value.description
  datacenters = each.value.datacenters
  rules       = each.value.rules
}

resource "consul_acl_role" "role" {
  depends_on = [consul_acl_policy.policy]
  for_each = {
    for role in var.roles : role.iac_id => role
  }
  name        = each.value.name
  description = each.value.description
  policies    = each.value.policy_names
}

resource "consul_acl_token" "token" {
  for_each = {
    for role in var.roles : role.iac_id => role
    if role.token_store != null
  }
  roles = [consul_acl_role.role[each.value.iac_id].name]
}

data "consul_acl_token_secret_id" "secret_id" {
  for_each = {
    for role in var.roles : role.iac_id => role
    if role.token_store != null
  }
  accessor_id = consul_acl_token.token[each.key].id
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for role in var.roles : role.iac_id => role
    if role.token_store != null && role.token_store.vault_kvv2_path != null
  }
  mount               = each.value.token_store.vault_kvv2_path
  name                = "token-${each.value.name}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = data.consul_acl_token_secret_id.secret_id[each.key].secret_id
    }
  )
}

data "vault_kv_secret_v2" "secret" {
  mount = "kvv2_vault"
  name  = "approle-consul_connect_pki"
}

resource "consul_certificate_authority" "connect_ca" {
  connect_provider = "vault"
  # https://developer.hashicorp.com/consul/docs/secure-mesh/certificate/vault?page=connect&page=ca&page=vault#enable-vault-as-the-ca
  config_json = jsonencode({
    Address       = var.prov_vault.address
    TLSServerName = split("//", var.prov_vault.address)[1]
    CAFile        = "/consul/secret/certs/ca.crt"
    # https://developer.hashicorp.com/consul/docs/secure-mesh/certificate/vault#configuration-reference
    # https://github.com/Mastercard/mangos/blob/f5d5530f43c82a959fe631811a862546c80fb366/mkosi.images/terraform/share/terraform/consul-connect.tf#L163
    # Token                    = data.vault_kv_secret_v2.secret.data["token"]
    # https://developer.hashicorp.com/vault/docs/agent-and-proxy/autoauth/methods/approle#configuration
    AuthMethod = {
      Type = "approle"
      Params = {
        role_id   = data.vault_kv_secret_v2.secret.data["role_id"]
        secret_id = data.vault_kv_secret_v2.secret.data["secret_id"]
      }
    }

    RootPkiPath              = "pki_consul_root"
    LeafCertTTL              = "72h"
    PrivateKeyType           = "rsa"
    PrivateKeyBits           = 2048
    IntermediatePkiPath      = "pki_consul_int"
    IntermediateCertTTL      = "8760h"
    RotationPeriod           = "2160h"
    ForceWithoutCrossSigning = true
  })
}
