terraform {
  required_providers {
    ldap = {
      source  = "l-with/ldap"
      version = ">=0.8.1"
    }
  }
}

provider "ldap" {
  host         = "opendj.day0.sololab"
  port         = "636"
  tls          = true
  tls_insecure = true

  bind_user     = "cn=Directory Manager"
  bind_password = "P@ssw0rd"
}

