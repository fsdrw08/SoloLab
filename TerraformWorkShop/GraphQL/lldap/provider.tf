terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">=2.5.4"
    }
    http = {
      source  = "hashicorp/http"
      version = ">=3.4.2"
    }
  }
}

provider "graphql" {
  url = "https://lldap.mgmt.sololab/api/graphql"
  headers = {
    "Authorization" = "${var.lldap_authz_header}"
  }
}
