terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.1.3"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
    schema_name = "System-SvcDisc-Quadlet-CoreDNS"
  }
}

provider "remote" {
  conn {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
}
