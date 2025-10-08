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
  # wildcard vyos
  {
    name = "wildcard.vyos"
    key = {
      algorithm = "RSA"
      rsa_bits  = 2048
    }
    cert = {
      dns_names = [
        "*.vyos.sololab",
        "*.vyos.sololab.dev",
      ]
      subject = {
        common_name  = "*.vyos.sololab"
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
  # CoreDNS external
  {
    name = "doh.vyos"
    key = {
      algorithm = "RSA"
      rsa_bits  = 2048
    }
    cert = {
      dns_names = [
        "doh.sololab.dev"
      ]
      ip_addresses = [
        "192.168.255.1",
      ]
      subject = {
        common_name  = "doh.sololab.dev"
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
  # postgresql for terraform backend
  {
    name = "tfbackend-pg"
    key = {
      algorithm = "RSA"
      rsa_bits  = 2048
    }
    cert = {
      dns_names = [
        "tf-backend-pg.vyos.sololab",
        "tf-backend-pg.day0.sololab"
      ]
      subject = {
        common_name  = "tfbackend-pg"
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
  # # https://github.com/mbookham7/crdb-terraform-azure-aks-single-region/blob/d0113db42803418908d8a6eee332c3266f141115/tls.tf#L201
  # {
  #   name = "cockroach_node_1"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     # https://www.cockroachlabs.com/docs/stable/authentication#using-a-custom-ca
  #     ip_addresses = [
  #       "192.168.255.1",
  #       "127.0.0.1"
  #     ]
  #     dns_names = [
  #       "localhost",
  #       "cockroach.day0.sololab"
  #     ]
  #     subject = {
  #       common_name  = "node"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "digital_signature",
  #       "key_encipherment",
  #       "server_auth",
  #       "client_auth",
  #     ]
  #   }
  # },
  # cockroach client
  # {
  #   name = "cockroach_client_root"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "root",
  #     ]
  #     subject = {
  #       common_name  = "root"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "digital_signature",
  #       "key_encipherment",
  #       "client_auth",
  #     ]
  #   }
  # },
  # day0
  # {
  #   name = "zot.day0"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 2048
  #   }
  #   cert = {
  #     dns_names = [
  #       "zot.day0.sololab"
  #     ]
  #     subject = {
  #       common_name  = "Zot Registry"
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
    name = "etcd-server.day0"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "etcd-0.day0.sololab",
        "localhost",
      ]
      subject = {
        common_name  = "etcd.day0.sololab"
        organization = "Sololab"
      }
      validity_period_hours = 43800
      allowed_uses = [
        "key_encipherment",
        "digital_signature",
        "server_auth",
        # https://blog.csdn.net/IT_DREAM_ER/article/details/107007186
        "client_auth",
      ]
    }
  },
  # {
  #   name = "etcd-guest"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     subject = {
  #       common_name  = "guest"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "cert_signing",
  #       "key_encipherment",
  #       "client_auth",
  #     ]
  #   }
  # },
  # cockpit
  {
    name = "cockpit.day0"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "cockpit.day0.sololab",
      ]
      subject = {
        common_name  = "cockpit.day0.sololab"
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
  # day0 wildcard
  {
    name = "wildcard.day0"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "*.day0.sololab"
      ]
      subject = {
        common_name  = "*.day0.sololab"
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
  # lldap
  {
    name = "lldap.day0"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "lldap.day0.sololab",
      ]
      subject = {
        common_name  = "lldap.day0.sololab"
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
  # vault
  {
    name = "vault.day1"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      ip_addresses = [
        "127.0.0.1"
      ]
      dns_names = [
        "vault.day1.sololab",
        "vault.service.consul",
      ]
      subject = {
        common_name  = "vault.day1.sololab"
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
  #   # https://github.com/hashicorp/microservices-architecture-on-aws/blob/0e73496fc694f402617859b95af97e8b784fb972/tls.tf#L42
  #   name = "consul"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "consul.day0.sololab",
  #       "consul.service.consul",
  #       "server.dc1.consul",
  #       "localhost"
  #     ]
  #     subject = {
  #       common_name  = "server.dc1.consul"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "digital_signature",
  #       "key_encipherment",
  #       "cert_signing",
  #       "crl_signing"
  #     ]
  #   }
  # },
  # {
  #   # https://github.com/hashicorp/microservices-architecture-on-aws/blob/0e73496fc694f402617859b95af97e8b784fb972/tls.tf#L42
  #   name = "nomad"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "nomad.day0.sololab",
  #     ]
  #     subject = {
  #       common_name  = "nomad.day0.sololab"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "digital_signature",
  #       "cert_signing",
  #       "crl_signing"
  #     ]
  #   }
  # },
  # opendj
  # {
  #   name = "opendj"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "opendj.day1.sololab"
  #     ]
  #     subject = {
  #       common_name  = "opendj.day1.sololab"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "key_encipherment",
  #       "digital_signature",
  #       "server_auth"
  #     ]
  #   }
  # },
  # keycloak
  # {
  #   name = "keycloak"
  #   key = {
  #     algorithm = "RSA"
  #     rsa_bits  = 4096
  #   }
  #   cert = {
  #     dns_names = [
  #       "keycloak.day1.sololab"
  #     ]
  #     subject = {
  #       common_name  = "keycloak.day1.sololab"
  #       organization = "Sololab"
  #     }
  #     validity_period_hours = 43800
  #     allowed_uses = [
  #       "key_encipherment",
  #       "digital_signature",
  #       "server_auth"
  #     ]
  #   }
  # },
]
