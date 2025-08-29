terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.0"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
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

provider "powerdns" {
  api_key        = var.prov_pdns.api_key
  server_url     = var.prov_pdns.server_url
  insecure_https = var.prov_pdns.insecure_https
}
