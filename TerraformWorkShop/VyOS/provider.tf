terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    vyos = {
      source  = "TGNThump/vyos"
      version = ">=2.1.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.1.2"
    }
  }
}

provider "vyos" {
  endpoint    = "https://${var.vyos_conn.address}:${var.vyos_conn.api_port}"
  api_key     = var.vyos_conn.api_key
  skip_saving = false
}

provider "remote" {
  max_sessions = 2

  conn {
    host     = var.vyos_conn.address
    port     = 22
    user     = var.vyos_conn.ssh_user
    password = var.vyos_conn.ssh_password
    sudo     = true
  }
}
