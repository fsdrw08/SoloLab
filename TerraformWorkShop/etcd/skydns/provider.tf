terraform {
  required_providers {
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "System-Day0-etcd-skydns"
  }
}

provider "etcd" {
  endpoints = var.prov_etcd.endpoints
  ca_cert   = var.prov_etcd.ca_cert
  username  = var.prov_etcd.username
  password  = var.prov_etcd.password
  skip_tls  = var.prov_etcd.skip_tls
}
