terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "1.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.1"
    }
    # archive = {
    #   source  = "hashicorp/archive"
    #   version = ">= 2.7.1"
    # }
  }

  # https://ruben-rodriguez.github.io/posts/minio-s3-terraform-backend/
  backend "s3" {
    bucket = "tfstate"               # Name of the S3 bucket
    key    = "Hyper-V/Dev-CentOS-VM" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio.service.consul" # Minio endpoint
    }

    access_key = "admin" # Access and secret keys
    secret_key = "P@ssw0rd"

    region                      = "main" # Region validation will be skipped
    skip_credentials_validation = true   # Skip AWS related checks and validations
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    skip_requesting_account_id  = true
    insecure                    = true
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  host     = var.hyperv.host
  port     = var.hyperv.port
  user     = var.hyperv.user
  password = var.hyperv.password
  https    = true
  insecure = true
  use_ntlm = true
  # tls_server_name = ""
  # cacert_path     = ""
  # cert_path       = ""
  # key_path        = ""
  script_path = "C:/Temp/terraform_%RAND%.cmd"
  timeout     = "30s"
}
