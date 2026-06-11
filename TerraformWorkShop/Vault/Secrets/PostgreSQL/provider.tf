terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.9.0"
    }
  }

  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/Vault/Secret-PostgreSQL"
  }
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
