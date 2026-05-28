terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.77.0"
    }
  }
  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/TFE/org"
    # access_token = ""
  }
}

provider "vault" {
  address         = var.prov_vault.address
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}

ephemeral "vault_kv_secret_v2" "provider_secret" {
  count = var.prov_tfe.token_reference == null ? 0 : 1
  mount = var.prov_tfe.token_reference.mount
  name  = var.prov_tfe.token_reference.name
}

provider "tfe" {
  hostname        = var.prov_tfe.hostname
  ssl_skip_verify = var.prov_tfe.ssl_skip_verify
  token           = var.prov_tfe.token_plaintext != null ? var.prov_tfe.token_plaintext : ephemeral.vault_kv_secret_v2.provider_secret[0].data[var.prov_tfe.token_reference.vault_kvv2.key]
}
