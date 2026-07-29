prov_vault = {
  address         = "https://vault.day1.sololab"
  skip_tls_verify = true
}

prov_sonatyperepo = {
  url = "https://nexus.day4.sololab"
  credential = {
    user = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-nexus"
        key   = "admin_username"
      }
    }
    password = {
      vault_kvv2 = {
        mount = "kvv2_others"
        name  = "app-nexus"
        key   = "admin_password"
      }
    }
  }
}

# https://help.sonatype.com/en/ldap.html
ldap = {
  auth_scheme               = "SIMPLE"
  hostname                  = "lldap.day1.sololab"
  name                      = "LLDAP"
  port                      = 636
  protocol                  = "LDAPS"
  search_base               = "dc=root,dc=sololab"
  user_email_name_attribute = "mail"
  user_id_attribute         = "uid"
  user_object_class         = "person"
  user_real_name_attribute  = "display_name"

  auth_username             = "cn=readonly,ou=people,dc=root,dc=sololab"
  auth_password             = "readonly"
  max_connection_attempts   = 5
  group_type                = "STATIC"
  group_base_dn             = "ou=groups"
  group_id_attribute        = "cn"
  group_member_attribute    = "member"
  group_member_format       = "uid=$${username},ou=people,dc=root,dc=sololab"
  group_object_class        = "groupOfUniqueNames"
  group_subtree             = false
  map_ldap_groups_to_roles  = true
  nexus_trust_store_enabled = true
  user_base_dn              = "ou=people"
  user_ldap_filter          = "(&(objectClass=person)(memberOf=cn=app-nexus-user,ou=groups,dc=root,dc=sololab))"
}

roles = [
  {
    id         = "app-nexus-admin"
    name       = "app-nexus-admin"
    privileges = ["nx-all"]
  },
  {
    id         = "metrics"
    name       = "metrics"
    privileges = ["nx-metrics-all"]
  },
]

local_users = [
  {
    # https://help.sonatype.com/en/prometheus.html
    user_id       = "metrics"
    email_address = "nexus-metrics@mail.sololab"
    first_name    = "metrics"
    last_name     = "prometheus"
    roles         = ["metrics"]
    status        = "active"
    password      = "P@ssw0rd"
  },
]
