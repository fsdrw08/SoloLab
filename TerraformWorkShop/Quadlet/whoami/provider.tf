terraform {
  required_providers {
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = ">= 5.4.0"
    # }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">=0.2.1"
    }
  }
  # backend "pg" {
  #   conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
  #   schema_name = "System-SvcDisc-Quadlet-whoami"
  # }
  backend "s3" {
    bucket = "tfstate"                    # Name of the S3 bucket
    key    = "System/Day0-Quadlet-whoami" # Name of the tfstate file

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

provider "remote" {
  conn {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user
    password = var.prov_remote.password
  }
}

# provider "vault" {
#   address = "${var.prov_vault.schema}://${var.prov_vault.address}"
#   token   = var.prov_vault.token
#   # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
#   skip_tls_verify = var.prov_vault.skip_tls_verify
# }
