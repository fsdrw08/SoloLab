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
    bucket = "tfstate"    # Name of the S3 bucket
    key    = "Consul/ACL" # Name of the tfstate file

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

ephemeral "vault_kv_secret_v2" "provider_secret" {
  for_each = {
    for key in keys(var.prov_consul.credential) : key => var.prov_consul.credential[key]
    if var.prov_consul.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

provider "consul" {
  scheme         = var.prov_consul.scheme
  address        = var.prov_consul.address
  datacenter     = var.prov_consul.datacenter
  insecure_https = var.prov_consul.insecure_https
  token          = contains(keys(var.prov_consul.credential), "token") ? var.prov_consul.credential["token"].plaintext != null ? var.prov_consul.credential["token"].plaintext : var.prov_consul.credential["token"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["token"].data[var.prov_consul.credential["token"].vault_kvv2.key] : null
}
