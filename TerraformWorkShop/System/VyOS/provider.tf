terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
    }
    # vyos = {
    #   source  = "Foltik/vyos"
    #   version = ">=0.3.3"
    # }
    consul = {
      source  = "hashicorp/consul"
      version = ">=2.20.0"
    }
  }
}

# https://registry.terraform.io/providers/neuspaces/system/latest/docs#usage-example
provider "system" {
  ssh {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  sudo = true
}

provider "consul" {
  address    = var.consul_conn.address
  datacenter = var.consul_conn.datacenter
  scheme     = var.consul_conn.scheme
  token      = var.consul_token_mgmt
}
