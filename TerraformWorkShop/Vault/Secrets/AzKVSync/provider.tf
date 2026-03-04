# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.58.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"        # Name of the S3 bucket
    key    = "Vault/AzKVSync" # Name of the tfstate file

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

provider "vault" {
  address = "${var.prov_vault.schema}://${var.prov_vault.address}"
  token   = var.prov_vault.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

provider "azurerm" {
  features {}
  subscription_id = var.prov_azurerm.subscription_id
}
