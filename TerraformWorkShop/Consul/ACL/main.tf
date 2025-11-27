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
    for role in var.roles : role.name => role
  }
  name        = each.value.name
  description = each.value.description
  policies    = each.value.policy_names
}

resource "consul_acl_token" "token" {
  for_each = {
    for role in var.roles : role.name => role
    if role.token_store != null
  }
  roles = [consul_acl_role.role[each.value.name].name]
}

data "consul_acl_token_secret_id" "secret_id" {
  for_each = {
    for role in var.roles : role.name => role
    if role.token_store != null
  }
  accessor_id = consul_acl_token.token[each.key].id
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for role in var.roles : role.name => role
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
  mount = "kvv2_vault_token"
  name  = "consul-ca"
}

data "consul_service" "vault" {
  name = "vault"
}

resource "consul_certificate_authority" "connect_ca" {
  connect_provider = "vault"
  # https://developer.hashicorp.com/consul/docs/secure-mesh/certificate/vault?page=connect&page=ca&page=vault#enable-vault-as-the-ca
  config_json = jsonencode({
    Address                  = "https://${data.consul_service.vault.service[0].address}:${data.consul_service.vault.service[0].port}"
    TLSServerName            = "vault.service.consul"
    CAFile                   = "/consul/secret/certs/ca.crt"
    Token                    = data.vault_kv_secret_v2.secret.data["token"]
    RootPkiPath              = "pki_consul_root"
    IntermediatePkiPath      = "pki_consul_int"
    LeafCertTTL              = "72h"
    RotationPeriod           = "2160h"
    IntermediateCertTTL      = "8760h"
    ForceWithoutCrossSigning = true
    PrivateKeyType           = "rsa"
    PrivateKeyBits           = 2048
  })
}
