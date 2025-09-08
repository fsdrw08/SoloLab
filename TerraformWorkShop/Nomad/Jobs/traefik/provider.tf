terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.0"
    }
  }
  # backend "pg" {
  #   conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
  #   schema_name = "Nomad-Job-Traefik"
  # }
  backend "s3" {
    bucket = "tfstate"           # Name of the S3 bucket
    key    = "Nomad/Job-Traefik" # Name of the tfstate file

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

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  # secret_id   = var.NOMAD_TOKEN
  # $env:NOMAD_TOKEN="xxxx"
}
