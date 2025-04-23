terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.7.0"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "Vault-consul-ACL_Token"
  }
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
