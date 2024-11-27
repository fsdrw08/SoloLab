terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.2.1"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@cockroach.day0.sololab/tfstate"
    schema_name = "HyperV-Dev-Fedora-Disk"
  }
  # backend "s3" {
  #   bucket = "tfstate"                 # Name of the S3 bucket
  #   key    = "Hyper-V/Dev-Fedora-Data" # Name of the tfstate file

  #   endpoints = {
  #     s3 = "http://192.168.255.1:9000" # Minio endpoint
  #   }

  #   access_key = "minio" # Access and secret keys
  #   secret_key = "miniosecret"

  #   region                      = "main" # Region validation will be skipped
  #   skip_credentials_validation = true   # Skip AWS related checks and validations
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   use_path_style              = true
  #   skip_requesting_account_id  = true
  # }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.hyperv.user
  password = var.hyperv.password
  host     = var.hyperv.host
  port     = var.hyperv.port
  https    = true
  insecure = true
  # use_ntlm = true
  # tls_server_name = ""
  # cacert_path     = ""
  # cert_path       = ""
  # key_path        = ""
  script_path = "C:/Temp/terraform_%RAND%.cmd"
  timeout     = "30s"
}
