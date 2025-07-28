terraform {
  required_providers {
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
    }
  }
}

provider "powerdns" {
  api_key        = var.prov_pdns.api_key
  server_url     = var.prov_pdns.server_url
  insecure_https = var.prov_pdns.insecure_https
}
