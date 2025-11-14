terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.2"
    }
    # ignition = {
    #   source  = "community-terraform-providers/ignition"
    #   version = ">=2.3.5"
    # }
    ct = {
      source  = "poseidon/ct"
      version = ">=0.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.1"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">=1.5.1"
    }
  }
  backend "s3" {
    bucket = "tfstate"              # Name of the S3 bucket
    key    = "Hyper-V/Day0-VM-FCOS" # Name of the tfstate file

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

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.prov_hyperv.user
  password = var.prov_hyperv.password
  host     = var.prov_hyperv.host
  port     = var.prov_hyperv.port
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

provider "powerdns" {
  api_key        = var.prov_pdns.api_key
  server_url     = var.prov_pdns.server_url
  insecure_https = var.prov_pdns.insecure_https
}
