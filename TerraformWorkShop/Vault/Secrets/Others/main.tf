locals {
  password_list = flatten([
    for secret in var.secrets : [
      for password in secret.generate_passwords : "${secret.name}-${password}"
    ]
    if secret.generate_passwords != []
  ])
}

ephemeral "random_password" "password" {
  for_each = {
    for password in local.password_list : password => password
  }
  length  = 10
  special = false
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for secret in var.secrets : secret.name => secret
  }
  mount = each.value.mount
  name  = each.key
  data_json_wo = jsonencode(
    merge(
      {
        for password in each.value.generate_passwords : "${password}" => ephemeral.random_password.password["${each.value.name}-${password}"].result
      },
      each.value.content
    )
  )
  data_json_wo_version = each.value.secret_version
  delete_all_versions  = true
}
