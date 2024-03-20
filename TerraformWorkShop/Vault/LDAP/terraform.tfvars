vault_ldap_auth_backend = {
  path         = "ldap"
  url          = "ldaps://lldap.infra.sololab"
  insecure_tls = false
  #   certificate  = data.terraform_remote_state.root_ca.outputs.root_cert_pem

  #   freeipa
  #   binddn       = "uid=system,cn=sysaccounts,cn=etc,dc=infra,dc=sololab"
  #   bindpass     = var.ldap_bindpass
  #   userdn       = "cn=users,cn=accounts,dc=infra,dc=sololab"
  #   userattr     = "mail"
  #   groupfilter  = "(&(objectClass=posixgroup)(cn=svc-vault-*)(member:={{.UserDN}}))"
  #   groupdn      = "cn=groups,cn=accounts,dc=infra,dc=sololab"
  #   groupattr    = "cn"

  # lldap
  binddn   = "cn=readonly,ou=people,dc=root,dc=sololab"
  bindpass = "readonly"
  userdn   = "ou=people,dc=root,dc=sololab"
  userattr = "uid"
  # do not use upper case group name
  userfilter  = "(&({{.UserAttr}}={{.Username}})(objectClass=person)(memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab))"
  groupdn     = "ou=groups,dc=root,dc=sololab"
  groupattr   = "cn"
  groupfilter = "(&(objectClass=groupOfUniqueNames)(cn=app-*)(|(memberUid={{.Username}})(member={{.UserDN}})(uniqueMember={{.UserDN}})))"
}

ldap_vault_entities = {
  users = {
    ou     = "ou=people,dc=root,dc=sololab"
    filter = "(&(objectClass=person)(memberOf=cn=sso_allow,ou=groups,dc=root,dc=sololab))"
  }
  groups = {
    ou     = "ou=groups,dc=root,dc=sololab"
    filter = "(&(objectClass=groupOfUniqueNames)(cn=app-*))"
  }
}
