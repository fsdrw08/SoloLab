terraform {
  required_providers {
    gitea = {
      source  = "go-gitea/gitea"
      version = ">= 0.6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
  }
  backend "consul" {
    address = "consul.day2.sololab"
    scheme  = "https"
    path    = "tfstate/Gitea/user"
  }
}

provider "vault" {
  address         = var.prov_vault.address
  skip_tls_verify = var.prov_vault.skip_tls_verify
  token           = var.prov_vault.token
}

ephemeral "vault_kv_secret_v2" "provider_secret" {
  for_each = {
    for key in keys(var.prov_gitea.credential) : key => var.prov_gitea.credential[key]
    if var.prov_gitea.credential[key].vault_kvv2 != null
  }
  mount = each.value.vault_kvv2.mount
  name  = each.value.vault_kvv2.name
}

provider "gitea" {
  base_url    = var.prov_gitea.base_url
  cacert_file = var.prov_gitea.cacert_file
  insecure    = var.prov_gitea.insecure
  token       = contains(keys(var.prov_gitea.credential), "token") ? var.prov_gitea.credential["token"].plaintext != null ? var.prov_gitea.credential["token"].plaintext : var.prov_gitea.credential["token"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["token"].data[var.prov_gitea.credential["token"].vault_kvv2.key] : null
  username    = contains(keys(var.prov_gitea.credential), "username") ? var.prov_gitea.credential["username"].plaintext != null ? var.prov_gitea.credential["username"].plaintext : var.prov_gitea.credential["username"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["username"].data[var.prov_gitea.credential["username"].vault_kvv2.key] : null
  password    = contains(keys(var.prov_gitea.credential), "password") ? var.prov_gitea.credential["password"].plaintext != null ? var.prov_gitea.credential["password"].plaintext : var.prov_gitea.credential["password"].vault_kvv2 == null ? null : ephemeral.vault_kv_secret_v2.provider_secret["password"].data[var.prov_gitea.credential["password"].vault_kvv2.key] : null
}
