terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.11.4"
    }
  }
  backend "s3" {
    bucket = "tfstate"        # Name of the S3 bucket
    key    = "MinIO/Day0-IAM" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.vyos.sololab" # Minio endpoint
    }

    access_key = "terraform" # Access and secret keys
    secret_key = "terraform"

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
