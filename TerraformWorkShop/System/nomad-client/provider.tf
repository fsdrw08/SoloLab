terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "System-Infra-System-Nomad_Client"
  }
}

# https://registry.terraform.io/providers/neuspaces/system/latest/docs#usage-example
provider "system" {
  ssh {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  sudo = true
}
