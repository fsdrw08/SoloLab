terraform {
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.21.0"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "Consul-Services"
  }
}

provider "consul" {
  scheme         = var.prov_consul.scheme
  address        = var.prov_consul.address
  datacenter     = var.prov_consul.datacenter
  token          = var.prov_consul.token
  insecure_https = var.prov_consul.insecure_https
}
