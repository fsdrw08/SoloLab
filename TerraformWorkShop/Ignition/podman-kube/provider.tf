terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.11.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">=2.20.0"
    }
  }
  backend "consul" {
    address = "192.168.255.1:8500"
    scheme  = "http"
    path    = "tfstate/Helm-Podman"
  }
}

provider "consul" {
  address    = "192.168.255.1:8500"
  datacenter = "dc1"
}
