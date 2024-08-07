terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.2.1"
    }
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.user
  password = var.password
  host     = var.host
  port     = 5986
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
