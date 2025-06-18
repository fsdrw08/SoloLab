module "policy_bindings" {
  source          = "../../modules/vault-policy_binding"
  policy_bindings = var.policy_bindings

}

resource "vault_mount" "kvv2" {
  path        = "kvv2/vault_token"
  type        = "kv-v2"
  description = "kvv2 secret backend for vault token"
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for token in module.policy_bindings.tokens : token.name => token
  }
  mount               = vault_mount.kvv2.path
  name                = each.value.name
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = each.value.token
    }
  )
}
