resource "ldap_entry" "ldap_accounts" {
  for_each = {
    for account in var.ldap_accounts : account.dn => account
  }

  dn = each.value.dn
  data_json = jsonencode(
    each.value.data
  )
}

resource "ldap_entry" "ldap_groups" {
  depends_on = [ldap_entry.ldap_accounts]
  for_each = {
    for group in var.ldap_groups : group.dn => group
  }

  dn = each.value.dn
  data_json = jsonencode(
    each.value.data
  )
}
