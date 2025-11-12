terraform {
  required_providers {
    sftpgo = {
      source  = "drakkan/sftpgo"
      version = ">= 0.0.19"
    }
  }
  backend "s3" {
    bucket = "tfstate" # Name of the S3 bucket
    key    = "SFTPGo"  # Name of the tfstate file

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

provider "sftpgo" {
  host     = var.prov_sftpgo.host
  username = var.prov_sftpgo.username
  password = var.prov_sftpgo.password
}
