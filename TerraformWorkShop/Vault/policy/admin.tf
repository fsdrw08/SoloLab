resource "vault_policy" "policy" {
  for_each = {
    for binding in var.policy_bindings : binding.policy_name => binding
  }
  # name   = "admin"
  # policy = <<-EOT
  # path "*" {
  #   capabilities = ["create", "read", "update", "patch", "delete", "list", "sudo"]
  # }
  # EOT
  name   = each.value.policy_name
  policy = each.value.policy_content
}

# put all group in external in to one data set
data "vault_identity_group" "external" {
  for_each = {
    for group in setunion(
      flatten([
        for binding in var.policy_bindings : binding.external_groups
    ])) : group => group
  }
  group_name = each.key
}

resource "vault_identity_group" "internal" {
  for_each = {
    for binding in var.policy_bindings : binding.policy_group => binding
  }
  name = each.value.policy_group
  type = "internal"
  policies = [
    vault_policy.policy[each.value.policy_name].name
  ]
  member_group_ids = [
    for group in each.value.external_groups : data.vault_identity_group.external[group].group_id
    # data.vault_identity_group.external.group_id
  ]
}
