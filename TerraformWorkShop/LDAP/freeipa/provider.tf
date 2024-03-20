terraform {
  required_providers {
    ldap = {
      source = "elastic-infra/ldap"
      version = "2.0.1"
    }
  }
}

provider "ldap" {
  ldap_host     = "ipa.infra.sololab"
  ldap_port     = 389
  bind_user     = "uid=admin,cn=users,cn=accounts,dc=infra,dc=sololab"
  bind_password = "P@ssw0rd"
}