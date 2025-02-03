prov_ldap = {
  host         = "opendj.day1.sololab"
  port         = "636"
  tls          = true
  tls_insecure = true

  bind_user     = "cn=Directory Manager"
  bind_password = "P@ssw0rd"
}

base_dn = "dc=root,dc=sololab"

ldap_accounts = [
  {
    dn = "uid=admin,ou=People,dc=root,dc=sololab"
    data = {
      objectClass  = ["top", "inetOrgPerson", "organizationalPerson", "person"]
      userPassword = ["{SSHA}9tYIWTF0A7+ipgncHEJJhRL9Vb/pydxL4A=="] # P@ssw0rd
      cn           = ["admin"]
      sn           = ["admin"]
      mail         = ["admin@mail.sololab"]
      # https://doc.openidentityplatform.org/opendj/admin-guide/chap-privileges-acis#about-privileges
      ds-privilege-name = ["password-reset"]
    }
  },
  {
    dn = "uid=readonly,ou=Services,dc=root,dc=sololab"
    data = {
      objectClass  = ["top", "inetOrgPerson", "organizationalPerson", "person"]
      userPassword = ["{SSHA}k/8CkwU7/1C/QM+Qw2uNkOqzOQxdv2qLwQ=="] # P@ssw0rd
      cn           = ["readonly"]
      sn           = ["readonly"]
      # https://doc.openidentityplatform.org/opendj/admin-guide/chap-privileges-acis#about-privileges
      ds-privilege-name = ["config-read"]
    }
  },
  {
    dn = "uid=user1,ou=People,dc=root,dc=sololab"
    data = {
      objectClass  = ["top", "inetOrgPerson", "organizationalPerson", "person"]
      userPassword = ["{SSHA}9tYIWTF0A7+ipgncHEJJhRL9Vb/pydxL4A=="] # P@ssw0rd
      cn           = ["user1"]
      sn           = ["user1"]
      mail         = ["user1@mail.sololab"]
    }
  }
]

ldap_groups = [
  {
    dn = "cn=Directory Administrators,ou=Groups,dc=root,dc=sololab"
    data = {
      objectClass = ["top", "groupOfUniqueNames"]
      ou          = ["Groups"]
      uniqueMember = [
        "uid=admin,ou=People,dc=root,dc=sololab",
      ]
    }
  },
  {
    dn = "cn=sso_allow,ou=Groups,dc=root,dc=sololab"
    data = {
      objectClass = ["top", "groupOfUniqueNames"]
      ou          = ["Groups"]
      uniqueMember = [
        "uid=admin,ou=People,dc=root,dc=sololab",
        "uid=user1,ou=People,dc=root,dc=sololab",
      ]
    }
  },
  {
    dn = "cn=App-Vault-Admin,ou=Groups,dc=root,dc=sololab"
    data = {
      objectClass = ["top", "groupOfUniqueNames"]
      ou          = ["Groups"]
      uniqueMember = [
        "uid=admin,ou=People,dc=root,dc=sololab",
      ]
    }
  },
  {
    dn = "cn=App-Consul-Auto_Config,ou=Groups,dc=root,dc=sololab"
    data = {
      objectClass = ["top", "groupOfUniqueNames"]
      ou          = ["Groups"]
      uniqueMember = [
        "uid=admin,ou=People,dc=root,dc=sololab",
        "uid=user1,ou=People,dc=root,dc=sololab",
      ]
    }
  },
  # {
  #   dn = "cn=App-Zot-Admin,ou=Groups,dc=root,dc=sololab"
  #   data = {
  #     objectClass = ["top", "groupOfUniqueNames"]
  #     ou          = ["Groups"]
  #     uniqueMember = [
  #       "uid=admin,ou=People,dc=root,dc=sololab",
  #     ]
  #   }
  # },
  # {
  #   dn = "cn=App-Zot-CU,ou=Groups,dc=root,dc=sololab"
  #   data = {
  #     objectClass = ["top", "groupOfUniqueNames"]
  #     ou          = ["Groups"]
  #     uniqueMember = [
  #       "uid=user1,ou=People,dc=root,dc=sololab",
  #     ]
  #   }
  # },
]
