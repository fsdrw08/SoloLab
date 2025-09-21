terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
    }
  }
  backend "s3" {
    bucket = "tfstate"                # Name of the S3 bucket
    key    = "VyOS/Container-Cockpit" # Name of the tfstate file

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

provider "system" {
  ssh {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  sudo = true
}

provider "vyos" {
  url = var.prov_vyos.url
  key = var.prov_vyos.key
}
