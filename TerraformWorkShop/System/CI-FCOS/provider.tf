terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">=4.0.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.11.0"
    }
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"        # Name of the S3 bucket
    key    = "System/CI-FCOS" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio.service.consul" # Minio endpoint
    }

    access_key = "admin" # Access and secret keys
    secret_key = "P@ssw0rd"

    region                      = "main" # Region validation will be skipped
    skip_credentials_validation = true   # Skip AWS related checks and validations
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
    skip_requesting_account_id  = true
    insecure                    = true
  }
}

provider "system" {
  ssh {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
}
