terraform {
  required_providers {
    lldap = {
      source  = "tasansga/lldap"
      version = ">= 0.3.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "LDAP-LLDAP-Day0"
  }
}

provider "lldap" {
  http_url                 = var.prov_lldap.http_url
  ldap_url                 = var.prov_lldap.ldap_url
  insecure_skip_cert_check = var.prov_lldap.insecure_skip_cert_check
  username                 = var.prov_lldap.username
  password                 = var.prov_lldap.password
  base_dn                  = var.prov_lldap.base_dn
}
