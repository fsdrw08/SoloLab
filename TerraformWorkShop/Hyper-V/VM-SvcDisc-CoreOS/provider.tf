terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.0.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = ">=2.2.2"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.4.0"
    }
  }
  backend "consul" {
    address = "192.168.255.1:8500"
    scheme  = "http"
    path    = "tfstate/SvcDisc-FCOS-VM"
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.hyperv_user
  password = var.hyperv_password
  host     = var.hyperv_host
  port     = var.hyperv_port
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
