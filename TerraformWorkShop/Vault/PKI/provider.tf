# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.11.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.2.3"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }

  backend "local" {
  }
}

locals {
  VAULT_ADDR = "vault.infra.sololab"
  token   = "hvs.MByVvHFB0jreYb4I23thar8k"
  skip_tls_verify = true

}

provider "vault" {
  address = "https://${local.VAULT_ADDR}"
  token   = local.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = local.skip_tls_verify
}
