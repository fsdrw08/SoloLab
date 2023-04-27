# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://github.com/sarubhai/aws_vault_config/blob/master/provider.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.15.0"
    }
    # local = {
    #   source  = "hashicorp/local"
    #   version = ">= 2.2.3"
    # }
    # tls = {
    #   source  = "hashicorp/tls"
    #   version = ">= 4.0.4"
    # }
  }

  backend "local" {
  }
}


locals {
  VAULT_ADDR      = "vault.infra.sololab"
  token           = "hvs.JubLUPriefDjcAhexm0H3mLv"
  skip_tls_verify = true
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs#example-usage
provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"

  address = "https://${local.VAULT_ADDR}"
  token   = local.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = local.skip_tls_verify
}
