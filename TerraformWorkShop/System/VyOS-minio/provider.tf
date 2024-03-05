terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    system = {
      source  = "neuspaces/system"
      version = ">=0.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.25.0"
    }
  }
  backend "consul" {
    address      = "consul.service.consul"
    scheme       = "http"
    path         = "tfstate/system/vyos-minio"
    access_token = "ec15675e-2999-d789-832e-8c4794daa8d7"
  }
}

# https://registry.terraform.io/providers/neuspaces/system/latest/docs#usage-example
provider "system" {
  ssh {
    host     = "192.168.255.1"
    port     = 22
    user     = "vyos"
    password = "vyos"
  }
  sudo = true
}

provider "vault" {
  # It is strongly recommended to configure this provider through the
  # environment variables described above, so that each user can have
  # separate credentials set in the environment.
  #
  # This will default to using $VAULT_ADDR
  # But can be set explicitly
  # address = "https://vault.example.net:8200"

  address = "https://vault.service.consul"
  token   = "95eba8ed-f6fc-958a-f490-c7fd0eda5e9e"
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = true
}
