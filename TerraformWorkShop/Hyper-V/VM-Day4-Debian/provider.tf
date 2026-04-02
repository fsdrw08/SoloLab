terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 1.2.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.7.1"
    }
  }
  backend "consul" {
    address = "consul.day1.sololab"
    scheme  = "https"
    path    = "tfstate/Hyper-V/VM-Day4-Debian"
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  host     = var.prov_hyperv.host
  port     = var.prov_hyperv.port
  user     = var.prov_hyperv.user
  password = var.prov_hyperv.password
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
