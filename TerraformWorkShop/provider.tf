terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 1.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.2"
    }
    ct = {
      source  = "poseidon/ct"
      version = ">= 0.13.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.1.3"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">= 1.5.1"
    }
    lldap = {
      source  = "tasansga/lldap"
      version = ">= 0.3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.0.0"
    }
    ldap = {
      source  = "l-with/ldap"
      version = "<= 0.9.1"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.5.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 3.25.1"
    }
  }
}
