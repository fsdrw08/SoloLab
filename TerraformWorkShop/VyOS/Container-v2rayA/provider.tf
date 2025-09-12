terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
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
  url = "https://vyos-api.day0.sololab"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
  # endpoint = "https://192.168.255.1:8443"
  # api_key  = "MY-HTTPS-API-PLAINTEXT-KEY"

}
