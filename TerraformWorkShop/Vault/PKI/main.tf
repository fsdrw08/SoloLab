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
  address = "http://192.168.255.31:8200"
  token   = "hvs.pqibSbWZDHGmY2ZBlT0IHKXG"

  default_3y_in_sec  = 94608000
  default_1y_in_sec  = 31536000
  default_1hr_in_sec = 3600
}

provider "vault" {
  address = local.address
  token   = local.token
}
