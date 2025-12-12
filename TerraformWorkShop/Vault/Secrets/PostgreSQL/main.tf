ephemeral "random_password" "password" {
  for_each = {
    for database in var.databases : database.name => database
  }
  length = 10
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for database in var.databases : database.name => database
  }
  mount = var.mount
  name  = each.key
  data_json_wo = jsonencode({
    username = each.value.username
    password = ephemeral.random_password.password[each.key].result
  })
  delete_all_versions = true
}
