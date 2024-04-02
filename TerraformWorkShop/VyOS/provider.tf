terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = "0.3.3"
    }
    # vyos = {
    #   source  = "TGNThump/vyos"
    #   version = "2.1.0"
    # }
  }
}

provider "vyos" {
  url = "https://192.168.255.1:8443"
  key = "MY-HTTPS-API-PLAINTEXT-KEY"
  # endpoint = "https://192.168.255.1:8443"
  # api_key  = "MY-HTTPS-API-PLAINTEXT-KEY"

}
