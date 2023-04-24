resource "vault_identity_group" "group" {
  for_each = var.identity_groups

  name = each.name
  type = each.type
  policies = each.policies
}

resource "vault_identity_group_alias" "group-alias" {
  
}