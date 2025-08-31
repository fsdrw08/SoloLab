terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.21.0"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "Consul-ACL"
  }
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

provider "consul" {
  scheme         = var.prov_consul.scheme
  address        = var.prov_consul.address
  datacenter     = var.prov_consul.datacenter
  token          = var.prov_consul.token
  insecure_https = var.prov_consul.insecure_https
}
