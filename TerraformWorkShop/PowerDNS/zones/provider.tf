terraform {
  required_providers {
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">= 1.5.1"
    }
  }
  backend "http" {
    // Best to define as environment variable $ export TF_HTTP_USERNAME=terraform
    username = "terraform"
    // Best to define as environment variable $ export TF_HTTP_PASSWORD=terraform
    password       = "terraform"
    address        = "https://lynx.vyos.sololab/client/devops/sololab-vyos/powerdns/state"
    lock_address   = "https://lynx.vyos.sololab/client/devops/sololab-vyos/powerdns/lock"
    unlock_address = "https://lynx.vyos.sololab/client/devops/sololab-vyos/powerdns/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
  }
}

provider "powerdns" {
  api_key        = var.prov_pdns.api_key
  server_url     = var.prov_pdns.server_url
  insecure_https = var.prov_pdns.insecure_https
}
