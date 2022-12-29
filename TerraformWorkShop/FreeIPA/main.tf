terraform {
  required_providers {
    freeipa = {
      version = "1.0.0"
      source  = "rework-space-com/freeipa"
    }
  }
}

provider "freeipa" {
  host = "ipa.infra.sololab"
  username = "admin"
  password = "P@ssw0rd"
  insecure = true
}