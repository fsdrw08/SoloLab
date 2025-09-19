terraform {
  required_providers {
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
    }
  }
  backend "http" {
    // Best to define as environment variable $ export TF_HTTP_USERNAME=terraform
    username = "terraform"
    // Best to define as environment variable $ export TF_HTTP_PASSWORD=terraform
    password       = "terraform"
    address        = "https://lynx.vyos.sololab/client/devops/sololab-vyos/haproxy/state"
    lock_address   = "https://lynx.vyos.sololab/client/devops/sololab-vyos/haproxy/lock"
    unlock_address = "https://lynx.vyos.sololab/client/devops/sololab-vyos/haproxy/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }
}

provider "vyos" {
  url = var.prov_vyos.url
  key = var.prov_vyos.key
}
