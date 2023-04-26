resource "vault_identity_group" "group" {
  for_each = var.groups

  name     = each.key
  type     = each.value.group_type
  policies = each.value.group_policies
}

# https://stackoverflow.com/questions/58343258/iterate-over-nested-data-with-for-for-each-at-resource-level
# https://developer.hashicorp.com/terraform/language/functions/flatten
resource "vault_identity_group_alias" "group_alias" {
  for_each = { for v in var.groups : v.group_alias => v }
  # for_each = var.groups.group_alias

  name           = each.value.
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.group[each.key].id
}
