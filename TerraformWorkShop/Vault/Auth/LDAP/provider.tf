# https://github.com/sarubhai/aws_vault_config/blob/master/provider.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    ldap = {
      source  = "l-with/ldap"
      version = "<= 0.9.1"
    }
  }

  backend "pg" {
    conn_str    = "postgres://terraform:terraform@tfbackend-pg.day0.sololab/tfstate?sslmode=require&sslrootcert="
    schema_name = "Vault-LDAP"
  }
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs#example-usage
# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
provider "vault" {
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"

  address         = var.prov_vault.address
  token           = var.prov_vault.token
  skip_tls_verify = var.prov_vault.skip_tls_verify
}

provider "ldap" {
  host          = var.prov_ldap.host
  port          = var.prov_ldap.port
  tls           = var.prov_ldap.tls
  tls_insecure  = var.prov_ldap.tls_insecure
  bind_user     = var.prov_ldap.bind_user
  bind_password = var.prov_ldap.bind_password
}
