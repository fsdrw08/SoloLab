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
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "System-Day1-System-Consul_Client"
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
  sudo = var.prov_system.sudo
}

provider "vault" {
  address = "${var.prov_vault.schema}://${var.prov_vault.address}"
  token   = var.prov_vault.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
