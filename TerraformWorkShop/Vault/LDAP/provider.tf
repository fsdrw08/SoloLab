# https://github.com/sarubhai/aws_vault_config/blob/master/provider.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs
# https://registry.terraform.io/providers/hashicorp/local/
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.25.0"
    }
    ldap = {
      source  = "l-with/ldap"
      version = ">=0.5.3"
    }
  }

  # backend "consul" {
  #   address      = "consul.service.consul"
  #   scheme       = "http"
  #   path         = "tfstate/vault/ldap"
  #   access_token = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  # }
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

  address         = "https://vault.infra.sololab:8200"
  token           = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  skip_tls_verify = true
}

provider "ldap" {
  host         = "lldap.infra.sololab"
  port         = "636"
  tls          = true
  tls_insecure = true

  bind_user     = "cn=admin,ou=people,dc=root,dc=sololab"
  bind_password = "P@ssw0rd"
}
