# https://github.com/Skatteetaten/vagrant-hashistack/blob/bfdc5c4c3edf49cc693174969b50616bd44c45e4/ansible/files/bootstrap/vault/post/terraform/pki/main.tf
# https://registry.terraform.io/providers/hashicorp/vault/latest/docs

terraform {
    required_providers {
      vault = {
        source  = "hashicorp/vault"
        version = ">= 3.11.0"
      }
    }
    
    backend "local" {
    }
}

locals {
    address = "http://192.168.255.31:8200"
    token = "hvs.pqibSbWZDHGmY2ZBlT0IHKXG"
}

provider "vault" {
    address = "${local.address}"
    token = "${local.token}"
}

#
# Create a Self Signed Certificate , to use as the Root Certificate Authority
#
resource "vault_mount" "pki" {
    path        = "pki"
    type        = "pki"
    description = "Vault's PKI backend"
    default_lease_ttl_seconds = 86400
    max_lease_ttl_seconds = 2592000
}

# https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_cert
resource "vault_pki_secret_backend_root_cert" "sololab" {
    depends_on = [ vault_mount.pki ]

    backend = vault_mount.pki.path

    type = "internal"
    common_name = "Sololab Root CA"
    ttl = "315360000"
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
    depends_on              = [ vault_pki_secret_backend_root_cert.sololab ]
    backend                 = vault_mount.pki.path
    issuing_certificates    = ["${local.address}/v1/pki/ca"]
    # issuing_certificates    = ["http://127.0.0.1:8200/v1/pki/ca"]
    crl_distribution_points = ["${local.address}/v1/pki/crl"]
    # crl_distribution_points = ["http://127.0.0.1:8200/v1/pki/crl"]
}

resource "vault_pki_secret_backend_role" "role" {
    depends_on  = [ vault_pki_secret_backend_root_cert.sololab ]
    backend     = vault_mount.pki.path
    name        = "default"
    allow_localhost = true
    allow_any_name = true
    enforce_hostnames = false
}

resource "vault_pki_secret_backend_intermediate_cert_request" "test" {
  depends_on  = [vault_mount.pki]
  backend     = vault_mount.pki.path
  type        = "internal"
  common_name = "app.my.domain"
}