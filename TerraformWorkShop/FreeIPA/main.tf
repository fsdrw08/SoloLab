terraform {
  required_providers {
    freeipa = {
      version = "1.0.0"
      source  = "rework-space-com/freeipa"
    }
    ldap = {
      source = "elastic-infra/ldap"
      version = "2.0.1"
    }
  }
}

provider "freeipa" {
  host = "ipa.infra.sololab"
  username = "admin"
  password = "P@ssw0rd"
  insecure = true
}

provider "ldap" {
  ldap_host     = "ipa.infra.sololab"
  ldap_port     = 389
  bind_user     = "uid=admin,cn=users,cn=accounts,dc=infra,dc=sololab"
  bind_password = "P@ssw0rd"
}