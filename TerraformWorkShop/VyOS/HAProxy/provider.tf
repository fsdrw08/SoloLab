terraform {
  required_providers {
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
    }
  }
}

provider "vyos" {
  url = var.prov_vyos.url
  key = var.prov_vyos.key
}
