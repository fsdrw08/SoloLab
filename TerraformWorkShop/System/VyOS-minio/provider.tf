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
  }
  backend "consul" {
    address      = "consul.service.consul"
    scheme       = "http"
    path         = "tfstate/system/vyos-lldap"
    access_token = "ec15675e-2999-d789-832e-8c4794daa8d7"
  }
}

# https://registry.terraform.io/providers/neuspaces/system/latest/docs#usage-example
provider "system" {
  ssh {
    host     = "192.168.255.1"
    port     = 22
    user     = "vyos"
    password = "vyos"
  }
  sudo = true
}
