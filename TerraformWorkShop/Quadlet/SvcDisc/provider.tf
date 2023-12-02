terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.11.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">=2.0.1"
    }
  }
  backend "s3" {
    bucket = "tfstate"      # Name of the S3 bucket
    key    = "quadlet/test" # Name of the tfstate file

    endpoints = {
      s3 = "http://192.168.255.1:9000" # Minio endpoint
    }

    access_key = "minio" # Access and secret keys
    secret_key = "miniosecret"

    region                      = "main" # Region validation will be skipped
    skip_credentials_validation = true   # Skip AWS related checks and validations
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    skip_requesting_account_id  = true
  }
}

provider "minio" {
  // required
  minio_server   = "192.168.255.1:9000"
  minio_user     = "minio"
  minio_password = "miniosecret"

}
