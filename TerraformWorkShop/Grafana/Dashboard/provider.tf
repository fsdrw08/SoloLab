terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 4.14.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"           # Name of the S3 bucket
    key    = "Grafana/Dashboard" # Name of the tfstate file

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
  count = var.prov_grafana.auth_reference.vault_kvv2 == null ? 0 : 1
  mount = var.prov_grafana.auth_reference.vault_kvv2.mount
  name  = var.prov_grafana.auth_reference.vault_kvv2.name
}

provider "grafana" {
  url  = var.prov_grafana.url
  auth = var.prov_grafana.auth_plaintext != null ? var.prov_grafana.auth_plaintext : ephemeral.vault_kv_secret_v2.provider_secret[0].data[var.prov_grafana.auth_reference.vault_kvv2.key]
}
