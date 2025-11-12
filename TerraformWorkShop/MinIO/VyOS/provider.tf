terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.11.4"
    }
  }
}

provider "minio" {
  minio_server   = var.prov_minio.minio_server
  minio_user     = var.prov_minio.minio_user
  minio_password = var.prov_minio.minio_password
  minio_ssl      = var.prov_minio.minio_ssl
}
