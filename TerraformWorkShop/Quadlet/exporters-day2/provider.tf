terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.1.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.2.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"                       # Name of the S3 bucket
    key    = "System/Day2-Quadlet-Exporters" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.day1.sololab" # Minio endpoint
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
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}

data "vault_kv_secret_v2" "provider_secret" {
  for_each = {
    for key in keys(var.prov_remote.credential) : key => var.prov_remote.credential[key]
    if var.prov_remote.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

locals {
  prov_remote = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = contains(keys(var.prov_remote.credential), "user") ? var.prov_remote.credential["user"].plaintext != null ? var.prov_remote.credential["user"].plaintext : var.prov_remote.credential["user"].vault_kvv2 == null ? null : data.vault_kv_secret_v2.provider_secret["user"].data[var.prov_remote.credential["user"].vault_kvv2.key] : null
    password = contains(keys(var.prov_remote.credential), "password") ? var.prov_remote.credential["password"].plaintext != null ? var.prov_remote.credential["password"].plaintext : var.prov_remote.credential["password"].vault_kvv2 == null ? null : data.vault_kv_secret_v2.provider_secret["password"].data[var.prov_remote.credential["password"].vault_kvv2.key] : null
  }
}

provider "remote" {
  conn {
    host     = local.prov_remote.host
    port     = local.prov_remote.port
    user     = local.prov_remote.user
    password = local.prov_remote.password
  }
}
