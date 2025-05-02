terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.2.1"
    }
  }
  # backend "pg" {
  #   conn_str    = "postgres://terraform:terraform@postgresql.day0.sololab/tfstate"
  #   schema_name = "HyperV-Infra-Disk-FCOS"
  # }
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
