terraform {
  required_providers {
    ldap = {
      source  = "l-with/ldap"
      version = ">=0.5.3"
    }
  }
}

provider "ldap" {
  host         = "lldap.infra.sololab"
  port         = "636"
  tls          = true
  tls_insecure = true

  bind_user     = "cn=admin,ou=people,dc=root,dc=sololab"
  bind_password = "P@ssw0rd"
}

