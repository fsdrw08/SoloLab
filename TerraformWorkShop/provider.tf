terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.5"
    }
    hyperv = {
      source  = "taliesins/hyperv"
      version = ">= 1.2.1"
    }
    vyos = {
      source  = "Foltik/vyos"
      version = ">= 0.3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.7.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.69.0"
    }
    lynx = {
      source  = "Clivern/lynx"
      version = ">= 0.3.0"
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
      version = ">= 3.0.2"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.1.3"
    }
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
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
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.22.0"
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
      version = ">= 4.3.0"
    }
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
  }
}
