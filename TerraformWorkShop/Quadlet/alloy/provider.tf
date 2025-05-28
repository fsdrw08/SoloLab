terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.1.3"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "System-Day1-Quadlet-Alloy"
  }
  # backend "local" {

  # }
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

provider "remote" {
  alias = "Day0"
  conn {
    host     = var.prov_remote.0.host
    port     = var.prov_remote.0.port
    user     = var.prov_remote.0.user
    password = var.prov_remote.0.password
  }
}

provider "remote" {
  alias = "Day1"
  conn {
    host     = var.prov_remote.1.host
    port     = var.prov_remote.1.port
    user     = var.prov_remote.1.user
    password = var.prov_remote.1.password
  }
}

provider "powerdns" {
  api_key        = var.prov_pdns.api_key
  server_url     = var.prov_pdns.server_url
  insecure_https = var.prov_pdns.insecure_https
}
