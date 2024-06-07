# https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/src/site/resources/Example.ldif#L2277
resource "ldap_entry" "user_admin" {
  dn = "uid=admin,ou=People,${var.base_dn}"
  data_json = jsonencode({
    objectClass       = ["top", "inetOrgPerson", "organizationalPerson", "person"]
    userPassword      = ["{SSHA}9tYIWTF0A7+ipgncHEJJhRL9Vb/pydxL4A=="] # P@ssw0rd
    cn                = ["admin"]
    sn                = ["admin"]
    ds-privilege-name = ["password-reset"]
  })
}

resource "ldap_entry" "group_admins" {
  dn = "cn=Directory Administrators,ou=Groups,${var.base_dn}"
  data_json = jsonencode({
    objectClass = ["top", "groupofuniquenames"]
    ou          = ["Groups"]
    uniqueMember = [
      "uid=admin,ou=People,${var.base_dn}",
    ]
  })
}

resource "ldap_entry" "group_sso_allow" {
  dn = "cn=sso_allow,ou=Groups,${var.base_dn}"
  data_json = jsonencode({
    objectClass = ["top", "groupofuniquenames"]
    ou          = ["Groups"]
    uniqueMember = [
      "uid=admin,ou=People,${var.base_dn}",
    ]
  })
}

resource "ldap_entry" "svc_readonly" {
  dn = "uid=readonly,ou=Services,${var.base_dn}"
  data_json = jsonencode({
    objectClass  = ["top", "inetOrgPerson", "organizationalPerson", "person"]
    userPassword = ["{SSHA}k/8CkwU7/1C/QM+Qw2uNkOqzOQxdv2qLwQ=="]
    cn           = ["readonly"]
    sn           = ["readonly"]
  })
}

resource "ldap_entry" "user_1" {
  dn = "uid=user1,ou=People,${var.base_dn}"
  data_json = jsonencode({
    objectClass  = ["top", "inetOrgPerson", "organizationalPerson", "person"]
    userPassword = ["{SSHA}9tYIWTF0A7+ipgncHEJJhRL9Vb/pydxL4A=="] # P@ssw0rd
    cn           = ["user1"]
    sn           = ["user1"]
  })
}

resource "ldap_entry" "group_zot_admin" {
  dn = "cn=App-Zot-Admin,ou=Groups,${var.base_dn}"
  data_json = jsonencode({
    objectClass = ["top", "groupofuniquenames"]
    ou          = ["Groups"]
    uniqueMember = [
      "uid=admin,ou=People,${var.base_dn}",
    ]
  })
}

resource "ldap_entry" "group_zot_cu" {
  dn = "cn=App-Zot-CU,ou=Groups,${var.base_dn}"
  data_json = jsonencode({
    objectClass = ["top", "groupofuniquenames"]
    ou          = ["Groups"]
    uniqueMember = [
      "uid=user1,ou=People,${var.base_dn}",
    ]
  })
}
