resource "vault_policy" "policy" {
  for_each = {
    for binding in var.policy_bindings : binding.policy_name => binding
  }
  name   = each.value.policy_name
  policy = each.value.policy_content
}

# put all group in external in to one data set
data "vault_identity_group" "external" {
  for_each = {
    for group in setunion(
      flatten([
        for binding in var.policy_bindings : binding.group_binding.external_groups
        if binding.group_binding != null
    ])) : group => group
  }
  group_name = each.key
}

resource "vault_identity_group" "internal" {
  for_each = {
    for binding in var.policy_bindings : binding.group_binding.policy_group => binding
    if binding.group_binding != null
  }
  name     = each.value.group_binding.policy_group
  type     = "internal"
  policies = [vault_policy.policy[each.value.policy_name].name]
  member_group_ids = [
    for group in each.value.group_binding.external_groups : data.vault_identity_group.external[group].group_id
  ]
}

resource "vault_token" "token" {
  for_each = {
    for binding in var.policy_bindings : binding.policy_name => binding
    if binding.token_binding != null
  }
  policies         = [vault_policy.policy[each.value.policy_name].name]
  no_parent        = each.value.token_binding.no_parent
  renewable        = each.value.token_binding.renewable
  ttl              = each.value.token_binding.ttl
  explicit_max_ttl = each.value.token_binding.explicit_max_ttl
  display_name     = each.value.token_binding.display_name
  period           = each.value.token_binding.period
}

output "tokens" {
  value = [
    for binding in var.policy_bindings : {
      name  = binding.policy_name
      token = vault_token.token[binding.policy_name].client_token
    }
    if binding.token_binding != null
  ]
}
