resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for secret in var.secrets : secret.name => secret
  }
  mount                = each.value.mount
  name                 = each.key
  data_json_wo         = jsonencode(each.value.content)
  data_json_wo_version = each.value.secret_version
  delete_all_versions  = true
}
