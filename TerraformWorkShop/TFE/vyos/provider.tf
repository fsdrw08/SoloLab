terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.70.0"
    }
  }
}

provider "tfe" {
  hostname        = var.prov_tfe.hostname
  token           = var.prov_tfe.token
  ssl_skip_verify = var.prov_tfe.ssl_skip_verify
}
