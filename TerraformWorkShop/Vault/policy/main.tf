module "policy_bindings" {
  source          = "../../modules/vault-policy_binding"
  policy_bindings = var.policy_bindings

}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for token in module.policy_bindings.tokens : token.name => token
  }
  mount               = "kvv2-vault_token"
  name                = each.value.name
  delete_all_versions = true
  data_json = jsonencode(
    {
      token  = each.value.token
      policy = each.value.name
    }
  )
}
