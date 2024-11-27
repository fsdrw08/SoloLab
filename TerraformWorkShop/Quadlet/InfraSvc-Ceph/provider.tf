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
    random = {
      source  = "hashicorp/random"
      version = ">=3.6.2"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">=0.3.3"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@cockroach.day0.sololab/tfstate"
    schema_name = "System-SvcDisc-Quadlet-Ceph"
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

provider "vyos" {
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}
