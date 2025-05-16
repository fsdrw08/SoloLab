terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.5.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.7.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "MinIO-Infra-IAM"
  }
}

provider "minio" {
  minio_server   = var.prov_minio.minio_server
  minio_user     = var.prov_minio.minio_user
  minio_password = var.prov_minio.minio_password
  minio_ssl      = var.prov_minio.minio_ssl
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
