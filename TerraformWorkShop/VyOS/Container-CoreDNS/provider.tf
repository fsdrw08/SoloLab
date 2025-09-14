terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
    }
  }
}

provider "system" {
  ssh {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  sudo = true
}

provider "vyos" {
  url = var.prov_vyos.url
  key = var.prov_vyos.key
}
