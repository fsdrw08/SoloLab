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
    vyos = {
      source  = "Foltik/vyos"
      version = ">=0.3.3"
    }
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

provider "vyos" {
  url = "https://192.168.255.1:8443"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
}
