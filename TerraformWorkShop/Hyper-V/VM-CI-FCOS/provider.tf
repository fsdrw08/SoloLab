terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.1.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.2"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = ">=2.3.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.1"
    }
  }
  backend "s3" {
    bucket = "tfstate"            # Name of the S3 bucket
    key    = "Hyper-V/CI-FCOS-VM" # Name of the tfstate file

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
  user     = var.hyperv_user
  password = var.hyperv_password
  host     = var.hyperv_host
  port     = var.hyperv_port
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
