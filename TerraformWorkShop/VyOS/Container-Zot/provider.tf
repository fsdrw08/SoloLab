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
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">=1.2.1"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
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
