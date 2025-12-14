ephemeral "random_password" "admin_password" {
  for_each = {
    for database in var.databases : database.name => database
  }
  length = 10
}

ephemeral "random_password" "user_password" {
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
    admin_password = ephemeral.random_password.admin_password[each.key].result
    user_name      = each.value.user_name
    user_password  = ephemeral.random_password.user_password[each.key].result
  })
  data_json_wo_version = each.value.secret_version
  delete_all_versions  = true
}
