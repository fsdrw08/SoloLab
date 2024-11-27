# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://github.com/sarubhai/aws_vault_config/blob/master/provider.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.2.0"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@cockroach.day0.sololab/tfstate"
    schema_name = "Vault-Consul-auto_config"
  }
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

  address         = var.vault_conn.address
  token           = var.vault_conn.token
  skip_tls_verify = var.vault_conn.skip_tls_verify
}
