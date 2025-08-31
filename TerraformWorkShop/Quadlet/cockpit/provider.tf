terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.1.3"
    }
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "System-Day0-Quadlet-Cockpit"
  }
  # backend "local" {

  # }
}

provider "remote" {
  conn {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
}

provider "etcd" {
  endpoints = var.prov_etcd.endpoints
  ca_cert   = var.prov_etcd.ca_cert
  username  = var.prov_etcd.username
  password  = var.prov_etcd.password
  skip_tls  = var.prov_etcd.skip_tls
}
