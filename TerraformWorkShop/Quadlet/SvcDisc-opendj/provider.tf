terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.1.3"
    }
    jks = {
      source  = "fhke/jks"
      version = ">=1.0.1"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
    schema_name = "System-SvcDisc-Quadlet-OpenDJ"
  }
}

provider "remote" {
  conn {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
}

provider "powerdns" {
  api_key        = var.pdns.api_key
  server_url     = var.pdns.server_url
  insecure_https = var.pdns.insecure_https
}
