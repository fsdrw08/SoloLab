terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 1.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    # ignition = {
    #   source  = "community-terraform-providers/ignition"
    #   version = ">=2.3.5"
    # }
    ct = {
      source  = "poseidon/ct"
      version = ">= 0.13.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.1"
    }
  }

  # https://ruben-rodriguez.github.io/posts/minio-s3-terraform-backend/
  backend "consul" {
    address = "consul.day1.sololab"
    scheme  = "https"
    path    = "tfstate/Hyper-V/VM-Day3-FCOS"
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.prov_hyperv.user
  password = var.prov_hyperv.password
  host     = var.prov_hyperv.host
  port     = var.prov_hyperv.port
  https    = true
  insecure = true
  use_ntlm = true
  # tls_server_name = ""
  # cacert_path     = ""
  # cert_path       = ""
  # key_path        = ""
  script_path = "C:/Temp/terraform_%RAND%.cmd"
  timeout     = "30s"
}

provider "vault" {
  address = "${var.prov_vault.schema}://${var.prov_vault.address}"
  token   = var.prov_vault.token
  # https://registry.terraform.io/providers/hashicorp/vault/latest/docs#skip_tls_verify
  skip_tls_verify = var.prov_vault.skip_tls_verify
}
