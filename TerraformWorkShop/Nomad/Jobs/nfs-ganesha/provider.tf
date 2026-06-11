terraform {
  required_providers {
    # null = {
    #   source  = "hashicorp/null"
    #   version = ">= 3.3.0"
    # }
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.6.1"
    }
  }
  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/Nomad/Job-NFS-Ganesha"
  }
}

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  # secret_id   = var.NOMAD_TOKEN
  # $env:NOMAD_TOKEN="xxxx"
}
