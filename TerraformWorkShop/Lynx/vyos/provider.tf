terraform {
  required_providers {
    lynx = {
      source  = "Clivern/lynx"
      version = ">= 0.3.0"
    }
  }
}

provider "lynx" {
  api_url = var.prov_lynx.api_url
  api_key = var.prov_lynx.api_key
}
