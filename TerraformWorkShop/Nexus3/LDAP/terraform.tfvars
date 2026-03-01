prov_nexus = {
  insecure = true
  url      = "https://nexus3.day3.sololab"
  username = "admin"
  password = "P@ssw0rd"
}

# prov_vault = {
#   address         = "https://vault.day0.sololab"
#   token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
#   skip_tls_verify = true
# }

# https://help.sonatype.com/en/ldap.html
ldap = {
  name                         = "LLDAP"
  protocol                     = "LDAPS"
  host                         = "lldap.day0.sololab"
  port                         = 636
  auth_schema                  = "SIMPLE"
  auth_username                = "cn=readonly,ou=people,dc=root,dc=sololab"
  auth_password                = "readonly"
  max_incident_count           = 5
  search_base                  = "dc=root,dc=sololab"
  group_type                   = "static"
  group_base_dn                = "ou=groups"
  group_id_attribute           = "cn"
  group_member_attribute       = "member"
  group_member_format          = "uid=$${username},ou=people,dc=root,dc=sololab"
  group_object_class           = "groupOfUniqueNames"
  group_subtree                = false
  ldap_groups_as_roles         = true
  use_trust_store              = true
  user_base_dn                 = "ou=people"
  user_email_address_attribute = "mail"
  user_id_attribute            = "uid"
  user_ldap_filter             = "(&(objectClass=person)(memberOf=cn=app-nexus-user,ou=groups,dc=root,dc=sololab))"
  user_object_class            = "person"
  user_real_name_attribute     = "display_name"
}

roles = [
  {
    name       = "app-nexus-admin"
    roleid     = "app-nexus-admin"
    privileges = ["nx-all"]
  },
]
