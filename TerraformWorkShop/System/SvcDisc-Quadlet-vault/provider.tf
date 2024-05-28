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
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@cockroach.mgmt.sololab/tfstate"
    schema_name = "System-SvcDisc-Quadlet-Vault"
  }
}

provider "system" {
  ssh {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
}
