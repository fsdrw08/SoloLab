terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.38.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day1.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "MinIO-Infra-Buckets"
  }
}

provider "minio" {
  minio_server   = var.prov_minio.minio_server
  minio_user     = var.prov_minio.minio_user
  minio_password = var.prov_minio.minio_password
  minio_ssl      = var.prov_minio.minio_ssl
}
