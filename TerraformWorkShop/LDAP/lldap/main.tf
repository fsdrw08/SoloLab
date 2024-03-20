# https://github.com/lldap/lldap/issues/643
resource "ldap_entry" "app-test-default" {
  dn = "uid=app-test-default,ou=groups,dc=root,dc=sololab"
  data_json = jsonencode({
    objectClass  = ["groupOfUniqueNames"]
    cn           = ["app-test-default"]
    uid          = ["app-test-default"]
    member       = ["uid=admin,ou=people,dc=root,dc=sololab"]
    uniquemember = ["uid=admin,ou=people,dc=root,dc=sololab"]
  })
}
