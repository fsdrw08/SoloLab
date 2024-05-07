# https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/src/site/resources/Example.ldif#L2277
resource "ldap_entry" "user_admin" {
  dn = "uid=admin,ou=People,${var.base_dn}"
  data_json = jsonencode({
    objectClass       = ["person", "inetOrgPerson", "organizationalPerson", "top"]
    userpassword      = ["{bcrypt}${bcrypt("P@ssw0rd", 12)}"]
    cn                = ["admin"]
    sn                = ["admin"]
    ds-privilege-name = ["password-reset"]
  })
  ignore_attributes = ["ds-privilege-name"]
}

resource "ldap_entry" "group_admins" {
  dn = "cn=Directory Administrators,ou=Groups,${var.base_dn}"
  data_json = jsonencode({
    objectClass = ["top", "groupofuniquenames"]
    ou          = ["Groups"]
    uniquemember = [
      "uid=admin,ou=People,${var.base_dn}",
    ]
  })
}

resource "ldap_entry" "svc_readonly" {
  dn = "uid=readonly,ou=Services,${var.base_dn}"
  data_json = jsonencode({
    objectClass  = ["person", "inetOrgPerson", "organizationalPerson", "top"]
    userpassword = ["{bcrypt}${bcrypt("P@ssw0rd", 12)}"]
    cn           = ["readonly"]
    sn           = ["readonly"]
  })
}
