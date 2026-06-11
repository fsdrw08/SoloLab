terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.9.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"             # Name of the S3 bucket
    key    = "Vault/Secret-Others" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.day1.sololab" # Minio endpoint
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

provider "vault" {
  address         = var.prov_vault.address
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}
