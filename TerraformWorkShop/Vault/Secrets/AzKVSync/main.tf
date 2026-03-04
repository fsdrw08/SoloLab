locals {
  az_secrets = flatten([
    for kvv2_secret in var.kvv2_secrets : [
      for secret_set in kvv2_secret.secret_sets : secret_set.value_ref_az_kv
      if secret_set.value_ref_az_kv != null
    ]
  ])
}

ephemeral "azurerm_key_vault_secret" "secret" {
  for_each = {
    for az_secret in local.az_secrets : az_secret.name => az_secret
  }
  key_vault_id = each.value.key_vault_id
  name         = each.value.name
}

resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for kvv2_secret in var.kvv2_secrets : "${kvv2_secret.mount}-${kvv2_secret.name}" => kvv2_secret
  }
  mount               = each.value.mount
  name                = each.value.name
  delete_all_versions = true
  data_json_wo = jsonencode(
    {
      for secret_set in each.value.secret_sets : secret_set.key => secret_set.value_string != null ? secret_set.value_string : ephemeral.azurerm_key_vault_secret.secret[secret_set.value_ref_az_kv.name].value
    }
  )
  data_json_wo_version = each.value.data_version
}
