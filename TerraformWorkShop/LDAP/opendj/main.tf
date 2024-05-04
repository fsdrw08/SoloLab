# resource "ldap_entry" "dn_root" {
#   dn = "dc=root,dc=sololab"
#   data_json = jsonencode({
#     objectClass = ["domain", "top"]
#     dc          = ["root"]
#     aci = [
#       "(target=\"ldap:///dc=root,dc=sololab\") (targetattr =\"*\")(version 3.0; acl \"allow all Admin group\"; allow(all,export,import,proxy) groupdn =\"ldap:///cn=Directory Administrators,ou=groups,dc=root,dc=sololab\";)",
#       "(targetcontrol=\"1.2.840.113556.1.4.805\") (version 3.0; acl \"Tree delete for Admins\"; allow(all) groupdn =\"ldap:///cn=Directory Administrators,ou=groups,dc=root,dc=sololab\";)"
#     ]
#   })
# }

resource "ldap_entry" "ou_people" {
  dn = "ou=people,dc=root,dc=sololab"
  data_json = jsonencode({
    objectClass = ["top", "organizationalUnit"]
    description = ["This is where you put the people"]
  })
  lifecycle {
    prevent_destroy = false
  }
}

resource "ldap_entry" "ou_groups" {
  dn = "ou=groups,dc=root,dc=sololab"
  data_json = jsonencode({
    objectClass = ["top", "organizationalUnit"]
  })
  lifecycle {
    prevent_destroy = false
  }
}

# https://github.com/OpenIdentityPlatform/OpenDJ/blob/fe3b09f4a34ebc81725fd7263990839afd345752/src/site/resources/Example.ldif#L2277
resource "ldap_entry" "user_admin" {
  depends_on = [ldap_entry.ou_people]
  dn         = "uid=admin,ou=people,dc=root,dc=sololab"
  data_json = jsonencode({
    objectClass  = ["person", "inetOrgPerson", "organizationalPerson", "top"]
    userpassword = ["P@ssw0rd"]
    cn           = ["admin"]
    sn           = ["admin"]
  })
  # comment ignore_attributes before first apply
  ignore_attributes = ["userpassword"]
}

resource "ldap_entry" "group_admins" {
  depends_on = [ldap_entry.ou_groups, ldap_entry.user_admin]
  dn         = "cn=Directory Administrators,ou=groups,dc=root,dc=sololab"
  data_json = jsonencode({
    objectClass  = ["top", "groupofuniquenames"]
    ou           = ["groups"]
    uniquemember = ["uid=admin,ou=people,dc=root,dc=sololab"]
  })
}
