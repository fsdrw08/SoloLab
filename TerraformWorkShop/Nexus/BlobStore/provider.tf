terraform {
  required_providers {
    sonatyperepo = {
      source  = "sonatype-nexus-community/sonatyperepo"
      version = ">= 1.13.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.9.0"
    }
  }
  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/Nexus/BlobStore"
  }
}

provider "vault" {
  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

ephemeral "vault_kv_secret_v2" "provider_secret" {
  for_each = {
    for key in keys(var.prov_sonatyperepo.credential) : key => var.prov_sonatyperepo.credential[key]
    if var.prov_sonatyperepo.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

locals {
  prov_sonatyperepo = {
    url      = var.prov_sonatyperepo.url
    user     = contains(keys(var.prov_sonatyperepo.credential), "user") ? var.prov_sonatyperepo.credential["user"].plaintext != null ? var.prov_sonatyperepo.credential["user"].plaintext : var.prov_sonatyperepo.credential["user"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["user"].data[var.prov_sonatyperepo.credential["user"].vault_kvv2.key] : null
    password = contains(keys(var.prov_sonatyperepo.credential), "password") ? var.prov_sonatyperepo.credential["password"].plaintext != null ? var.prov_sonatyperepo.credential["password"].plaintext : var.prov_sonatyperepo.credential["password"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["password"].data[var.prov_sonatyperepo.credential["password"].vault_kvv2.key] : null
  }
}

provider "sonatyperepo" {
  url      = local.prov_sonatyperepo.url
  username = local.prov_sonatyperepo.user
  password = local.prov_sonatyperepo.password
}
