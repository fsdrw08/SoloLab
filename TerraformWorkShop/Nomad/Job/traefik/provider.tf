terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "Nomad-Job-Traefik"
  }
}

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  # secret_id   = var.NOMAD_TOKEN
  # $env:NOMAD_TOKEN="xxxx"
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs#example-usage
provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
