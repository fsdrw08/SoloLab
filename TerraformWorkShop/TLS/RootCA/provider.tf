terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">=2.5.1"
    }
  }
}
