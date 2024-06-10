root_ca = {
  key = {
    algorithm = "RSA"
    rsa_bits  = "2048"
  }
  cert = {
    subject = {
      common_name         = "Sololab Root CA"
      country             = "CN"
      locality            = "Foshan"
      organization        = "Sololab"
      organizational_unit = "Infra"
      province            = "GD"
      street_address      = []
    }
    validity_period_hours = 175296 # (365 * 24 * 20) + (24 * 4) # 20 years
    # https://github.com/hashicorp/vault-guides/blob/87f2fe347b581ad46e2e0a4b8a540f227cecb4f5/operations/benchmarking/terraform-aws-vault-benchmark/terraform/ssl.tf#L66
    allowed_uses = [
      "cert_signing",
      "crl_signing",
      "key_encipherment",
      "digital_signature",
      "server_auth",
      "client_auth",
    ]
  }
}

int_ca = {
  key = {
    algorithm = "RSA"
    rsa_bits  = "2048"
  }
  cert = {
    subject = {
      common_name         = "Sololab Intermediate CA1"
      country             = "CN"
      locality            = "Foshan"
      organization        = "Sololab"
      organizational_unit = "Infra"
      province            = "GD"
      street_address      = []
    }
    validity_period_hours = 175296 # (365 * 24 * 20) + (24 * 4) # 20 years
    allowed_uses = [
      "cert_signing",
      "crl_signing",
      "key_encipherment",
      "digital_signature",
      "server_auth",
      "client_auth",
    ]
  }
}

certs = [
  # vyos api
  {
    name = "vyos"
    key = {
      algorithm = "RSA"
      rsa_bits  = 2048
    }
    cert = {
      dns_names = [
        "vyos-api.mgmt.sololab"
      ]
      subject = {
        common_name  = "vyos api"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
      ]
    }
  },
  # cockroach node
  # https://github.com/mbookham7/crdb-terraform-azure-aks-single-region/blob/d0113db42803418908d8a6eee332c3266f141115/tls.tf#L201
  {
    name = "cockroach_node_1"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      ip_addresses = [
        "192.168.255.1",
        "127.0.0.1"
      ]
      dns_names = [
        "localhost",
        "cockroach.mgmt.sololab"
      ]
      subject = {
        common_name  = "node"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "digital_signature",
        "key_encipherment",
        "server_auth",
        "client_auth",
      ]
    }
  },
  # cockroach client
  {
    name = "cockroach_client_root"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "root",
      ]
      subject = {
        common_name  = "root"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "digital_signature",
        "key_encipherment",
        "client_auth",
      ]
    }
  },
  # traefik
  {
    name = "traefik"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = ["traefik.mgmt.sololab"]
      subject = {
        common_name  = "traefik.mgmt.sololab"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
      ]
    }
  },
  # opendj
  {
    name = "opendj"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "opendj.mgmt.sololab",
        "opendj.service.consul",
      ]
      subject = {
        common_name  = "opendj.mgmt.sololab"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth"
      ]
    }
  },
  # zot
  {
    name = "zot"
    key = {
      algorithm = "RSA"
      rsa_bits  = 2048
    }
    cert = {
      dns_names = [
        "zot.mgmt.sololab"
      ]
      subject = {
        common_name  = "Zot Registry"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
      ]
    }
  },
  # cockpit
  {
    name = "cockpit"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "cockpit.mgmt.sololab",
      ]
      subject = {
        common_name  = "cockpit.mgmt.sololab"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth"
      ]
    }
  },
  # vault
  {
    name = "vault"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      ip_addresses = [
        "127.0.0.1"
      ]
      dns_names = [
        "vault.mgmt.sololab",
        "vault.service.consul",
      ]
      subject = {
        common_name  = "vault.mgmt.sololab"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
        "client_auth"
      ]
    }
  },
  # {
  #   name = "wildcard"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = ["*.service.consul"]
  #     subject = {
  #       common_name  = "service.consul"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "key_encipherment",
  #       "digital_signature",
  #       "server_auth",
  #     ]
  #   }
  # },
  {
    # https://github.com/hashicorp/microservices-architecture-on-aws/blob/0e73496fc694f402617859b95af97e8b784fb972/tls.tf#L42
    name = "consul"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "consul.mgmt.sololab",
        "consul.service.consul",
        "server.dc1.consul",
        "localhost"
      ]
      subject = {
        common_name  = "server.dc1.consul"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "digital_signature",
        "cert_signing",
        "crl_signing"
      ]
    }
  },
  # {
  #   name = "minio"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "minio.service.consul",
  #       "localhost"
  #     ]
  #     subject = {
  #       common_name  = "minio.service.consul"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "key_encipherment",
  #       "digital_signature",
  #       "server_auth",
  #     ]
  #   }
  # },
]
