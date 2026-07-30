terraform {
  required_providers {
    nexus = {
      source  = "datadrivers/nexus"
      version = ">= 2.8.0"
    }
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = ">= 5.9.0"
    # }
  }
  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/Nexus/Repository/Docker"
    # access_token = ""
  }
}

provider "nexus" {
  insecure = var.prov_nexus.insecure
  url      = var.prov_nexus.url
  username = var.prov_nexus.username
  password = var.prov_nexus.password
}

# provider "vault" {
#   address         = var.prov_vault.address
#   token           = var.prov_vault.token
#   skip_tls_verify = var.prov_vault.skip_tls_verify
# }
