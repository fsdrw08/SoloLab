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
  for_each = {
    for key in keys(var.prov_grafana.credential) : key => var.prov_grafana.credential[key]
    if var.prov_grafana.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

provider "grafana" {
  url  = var.prov_grafana.url
  auth = contains(keys(var.prov_grafana.credential), "auth") ? var.prov_grafana.credential["auth"].plaintext != null ? var.prov_grafana.credential["auth"].plaintext : var.prov_grafana.credential["auth"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["auth"].data[var.prov_grafana.credential["auth"].vault_kvv2.key] : null
}
