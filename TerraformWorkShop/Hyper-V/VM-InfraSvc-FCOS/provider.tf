terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">=1.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.2"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = ">=2.3.3"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.1"
    }
  }

  # https://ruben-rodriguez.github.io/posts/minio-s3-terraform-backend/
  backend "pg" {
    conn_str    = "postgres://terraform:terraform@192.168.255.1/tfstate"
    schema_name = "HyperV-InfraSvc-VM-FCOS"
  }
}

# https://registry.terraform.io/providers/taliesins/hyperv/latest/docs
provider "hyperv" {
  user     = var.hyperv.user
  password = var.hyperv.password
  host     = var.hyperv.host
  port     = var.hyperv.port
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
