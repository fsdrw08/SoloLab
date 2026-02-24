terraform {
  required_providers {
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 2.8.1"
    }
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
    }
  }

  backend "s3" {
    bucket = "tfstate"      # Name of the S3 bucket
    key    = "Zitadel/Day0" # Name of the tfstate file

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

provider "zitadel" {
  domain           = var.prov_zitadel.domain
  insecure         = var.prov_zitadel.insecure
  port             = var.prov_zitadel.port
  jwt_profile_file = var.prov_zitadel.jwt_profile_file
}

provider "etcd" {
  endpoints = var.prov_etcd.endpoints
  ca_cert   = var.prov_etcd.ca_cert
  username  = var.prov_etcd.username
  password  = var.prov_etcd.password
  skip_tls  = var.prov_etcd.skip_tls
}
