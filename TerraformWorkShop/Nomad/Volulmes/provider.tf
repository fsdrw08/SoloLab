terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.1"
    }
  }
  backend "s3" {
    bucket = "tfstate"       # Name of the S3 bucket
    key    = "Nomad/Volumes" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.day0.sololab" # Minio endpoint
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

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  # secret_id   = var.NOMAD_TOKEN
  # $env:NOMAD_TOKEN="xxxx"
}
