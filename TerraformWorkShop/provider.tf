terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.3.0"
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
      version = ">= 3.3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.8.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.78.0"
    }
    lynx = {
      source  = "Clivern/lynx"
      version = ">= 0.3.0"
    }
    powerdns = {
      source  = "pyama86/powerdns"
      version = ">= 1.5.1"
    }
    ct = {
      source  = "poseidon/ct"
      version = ">= 0.14.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.9.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.2.0"
    }
    remote = {
      source  = "tenstad/remote"
      version = ">= 0.2.1"
    }
    etcd = {
      source  = "Ferlab-Ste-Justine/etcd"
      version = ">= 0.11.0"
    }
    lldap = {
      source  = "tasansga/lldap"
      version = ">= 0.4.1"
    }
    zitadel = {
      source  = "zitadel/zitadel"
      version = ">= 3.3.0"
    }
    # sftpgo = {
    #   source  = "drakkan/sftpgo"
    #   version = ">= 0.0.24"
    # }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.10.1"
    }
    ldap = {
      source  = "l-with/ldap"
      version = "<= 0.9.1"
    }
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.23.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.6.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.9.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = ">= 3.38.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">= 4.39.0"
    }
    system = {
      source  = "neuspaces/system"
      version = ">= 0.5.0"
    }
    nexus = {
      source  = "datadrivers/nexus"
      version = ">= 2.8.0"
    }
    gitea = {
      source  = "go-gitea/gitea"
      version = ">= 0.7.0"
    }
    gitea-unofficial = {
      source  = "maxsargentdev/gitea"
      version = ">= 0.12.0"
    }
  }
}
