terraform {
  required_providers {
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
    }
  }
}

provider "powerdns" {
  api_key        = var.pdns.api_key
  server_url     = var.pdns.server_url
  insecure_https = var.pdns.insecure_https
}
