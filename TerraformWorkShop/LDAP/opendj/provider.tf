terraform {
  required_providers {
    ldap = {
      source  = "l-with/ldap"
      version = "0.8.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
    schema_name = "Day1-OpenDJ"
  }
}

provider "ldap" {
  host         = "opendj.day1.sololab"
  port         = "636"
  tls          = true
  tls_insecure = true

  bind_user     = "cn=Directory Manager"
  bind_password = "P@ssw0rd"
}

