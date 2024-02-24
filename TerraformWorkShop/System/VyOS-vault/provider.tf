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
    path         = "tfstate/system/vyos-vault"
    access_token = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
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
