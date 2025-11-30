terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.11.4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"   # Name of the S3 bucket
    key    = "MinIO/IAM" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.vyos.sololab" # Minio endpoint
    }

    access_key = "minioadmin" # Access and secret keys
    secret_key = "minioadmin"

    region                      = "main" # Region validation will be skipped
    skip_credentials_validation = true   # Skip AWS related checks and validations
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true
    insecure                    = true
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
