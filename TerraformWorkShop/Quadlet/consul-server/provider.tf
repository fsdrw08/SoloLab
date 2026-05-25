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
      version = ">= 0.2.1"
    }
  }
  backend "s3" {
    bucket = "tfstate"                    # Name of the S3 bucket
    key    = "System/Day2-Quadlet-Consul" # Name of the tfstate file

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
  count = var.prov_remote.credential_reference == null ? 0 : 1
  mount = var.prov_remote.credential_reference.vault_kvv2.mount
  name  = var.prov_remote.credential_reference.vault_kvv2.name
}

locals {
  prov_remote_credential_map = var.prov_remote.credential_reference == null ? {} : {
    for item in var.prov_remote.credential_reference.value_sets : item.name => item.value_ref_key
  }
  prov_remote = {
    host     = var.prov_remote.host
    port     = var.prov_remote.port
    user     = var.prov_remote.user != null ? var.prov_remote.user : data.vault_kv_secret_v2.provider_secret.0.data[lookup(local.prov_remote_credential_map, "user", "user")]
    password = var.prov_remote.password != null ? var.prov_remote.password : data.vault_kv_secret_v2.provider_secret.0.data[lookup(local.prov_remote_credential_map, "password", "password")]
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
