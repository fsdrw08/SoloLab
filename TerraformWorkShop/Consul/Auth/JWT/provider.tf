terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.22.1"
    }
  }

  backend "s3" {
    bucket = "tfstate"         # Name of the S3 bucket
    key    = "Consul/Auth-JWT" # Name of the tfstate file

    endpoints = {
      s3 = "https://minio-api.day1.sololab" # Minio endpoint
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

provider "vault" {
  address         = var.prov_vault.address
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}

ephemeral "vault_kv_secret_v2" "provider_secret" {
  count = var.prov_consul.token_reference.vault_kvv2 == null ? 0 : 1
  mount = var.prov_consul.token_reference.vault_kvv2.mount
  name  = var.prov_consul.token_reference.vault_kvv2.name
}

provider "consul" {
  scheme         = var.prov_consul.scheme
  address        = var.prov_consul.address
  datacenter     = var.prov_consul.datacenter
  insecure_https = var.prov_consul.insecure_https
  token          = var.prov_consul.token_reference.vault_kvv2 == null ? var.prov_consul.token_plaintext : ephemeral.vault_kv_secret_v2.provider_secret.0.data[var.prov_consul.token_reference.vault_kvv2.key]
}
