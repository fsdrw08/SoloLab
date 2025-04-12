# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.7.0"
    }
  }
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate"
    schema_name = "Vault-PKI-Certs"
  }
}

provider "vault" {
  address = "${var.prov_vault.schema}://${var.prov_vault.address}"
  token   = var.prov_vault.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
