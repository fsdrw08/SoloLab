module "policy_bindings" {
  source          = "../../modules/vault-policy_binding"
  policy_bindings = var.policy_bindings

}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for token in module.policy_bindings.tokens : token.name => token
  }
  mount               = var.vault_secret_backend
  name                = "token-${replace(each.value.name, "-", "_")}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token  = each.value.token
      policy = each.value.name
    }
  )
}
