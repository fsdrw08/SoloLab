# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://github.com/sarubhai/aws_vault_config/blob/master/provider.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
terraform {
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
  }
  backend "s3" {
    bucket = "tfstate"        # Name of the S3 bucket
    key    = "Nomad/ACL-OIDC" # Name of the tfstate file

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

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs#example-usage
provider "vault" {
  address         = var.prov_vault.address
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}

ephemeral "vault_kv_secret_v2" "provider_secret" {
  for_each = {
    for key in keys(var.prov_nomad.credential) : key => var.prov_nomad.credential[key]
    if var.prov_nomad.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

provider "nomad" {
  address     = var.prov_nomad.address
  skip_verify = var.prov_nomad.skip_verify
  secret_id   = contains(keys(var.prov_nomad.credential), "secret_id") ? var.prov_nomad.credential["secret_id"].plaintext != null ? var.prov_nomad.credential["secret_id"].plaintext : var.prov_nomad.credential["secret_id"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["secret_id"].data[var.prov_nomad.credential["secret_id"].vault_kvv2.key] : null
}
