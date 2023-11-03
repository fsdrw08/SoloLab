terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.0.4"
    }
  }
  backend "consul" {
    address = "192.168.255.1:8500"
    scheme  = "http"
    path    = "tfstate/Dev-Fedora-Data"
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.provider_hyperv.user
  password = var.provider_hyperv.password
  host     = var.provider_hyperv.host
  port     = var.provider_hyperv.port
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
