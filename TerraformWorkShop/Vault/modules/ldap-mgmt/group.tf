resource "vault_identity_group" "group" {
  for_each = var.vault_groups

  name     = each.key
  type     = each.value.type
  policies = each.value.policies
  metadata = each.value.metadata
}

locals {
  # https://discuss.hashicorp.com/t/using-flatten-on-a-nested-map-of-differing-value-types/11901/7
  # https://stackoverflow.com/questions/58343258/iterate-over-nested-data-with-for-for-each-at-resource-level
  # https://developer.hashicorp.com/terraform/language/functions/flatten
  group_alias = flatten([
    for key, group in var.vault_groups : [
      for alias in group.alias : {
        alias_name = alias
        group_name = key
      }
    ]
  ])
}

resource "vault_identity_group_alias" "group_alias" {
  depends_on = [
    vault_ldap_auth_backend.ldap,
    vault_identity_group.group
  ]

  for_each = {
    for individual_alias in local.group_alias : individual_alias.alias_name => individual_alias
  }

  name           = each.value.alias_name
  mount_accessor = vault_ldap_auth_backend.ldap.accessor
  canonical_id   = vault_identity_group.group[each.value.group_name].id
}
