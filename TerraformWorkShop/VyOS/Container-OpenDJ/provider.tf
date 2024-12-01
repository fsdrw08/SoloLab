terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">=0.5.0"
    }
    jks = {
      source  = "fhke/jks"
      version = ">=1.0.1"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">=0.3.3"
    }
  }
}

provider "system" {
  ssh {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  sudo = true
}

provider "vyos" {
  url = var.vyos_conn.url
  key = var.vyos_conn.key
}
