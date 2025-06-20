resource "consul_acl_policy" "policy" {
  for_each = {
    for policy in var.policy_bindings : policy.name => policy
  }
  name        = each.value.name
  description = each.value.description
  datacenters = each.value.datacenters
  rules       = each.value.rules
}

resource "consul_acl_role" "role" {
  for_each = {
    for policy in var.policy_bindings : policy.name => policy
    if policy.role != null
  }
  name        = each.value.role.name
  description = each.value.role.description
  policies    = [consul_acl_policy.policy[each.key].id]
}

resource "consul_acl_token" "token" {
  for_each = {
    for policy in var.policy_bindings : policy.name => policy
    if policy.token != null
  }
  description = each.value.description
  policies    = [consul_acl_policy.policy[each.key].name]

}

data "consul_acl_token_secret_id" "secret_id" {
  for_each = {
    for policy in var.policy_bindings : policy.name => policy
    if policy.token != null
  }
  accessor_id = consul_acl_token.token[each.key].id
}


resource "vault_kv_secret_v2" "secret" {
  for_each = {
    for policy in var.policy_bindings : policy.name => policy
    if policy.token != null
  }
  mount               = each.value.token.vault_kvv2_path
  name                = "token-${each.value.name}"
  delete_all_versions = true
  data_json = jsonencode(
    {
      token = data.consul_acl_token_secret_id.secret_id[each.key].secret_id
    }
  )
}
