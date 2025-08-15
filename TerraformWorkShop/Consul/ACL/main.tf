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
  }
  roles = [consul_acl_role.role[each.value.name].name]
}

data "consul_acl_token_secret_id" "secret_id" {
  for_each = {
    for role in var.roles : role.name => role
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
