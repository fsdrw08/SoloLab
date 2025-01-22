terraform {
  required_providers {
    ldap = {
      source  = "l-with/ldap"
      version = "<=0.9.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
    schema_name = "LDAP-OpenDJ-Day1"
  }
}

provider "ldap" {
  host         = var.prov_ldap.host
  port         = var.prov_ldap.port
  tls          = var.prov_ldap.tls
  tls_insecure = var.prov_ldap.tls_insecure

  bind_user     = var.prov_ldap.bind_user
  bind_password = var.prov_ldap.bind_password
}

