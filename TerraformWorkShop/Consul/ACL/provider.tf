terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.22.1"
    }
  }

  backend "s3" {
    bucket = "tfstate"    # Name of the S3 bucket
    key    = "Consul/ACL" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.day0.sololab" # Minio endpoint
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
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

provider "consul" {
  scheme         = var.prov_consul.scheme
  address        = var.prov_consul.address
  datacenter     = var.prov_consul.datacenter
  token          = var.prov_consul.token
  insecure_https = var.prov_consul.insecure_https
}
