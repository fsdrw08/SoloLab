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
    allowed_uses = [
      "cert_signing",
      "crl_signing",
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
    ]
  }
}

certs = [
  {
    name = "sws"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "sws.infra.consul",
        "localhost"
      ]
      subject = {
        common_name  = "sws.infra.consul"
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
  {
    name = "wildcard"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = ["*.service.consul"]
      subject = {
        common_name  = "service.consul"
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
  {
    name = "vault"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "vault.service.consul"
      ]
      subject = {
        common_name  = "vault.service.consul"
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
  {
    # https://github.com/hashicorp/microservices-architecture-on-aws/blob/0e73496fc694f402617859b95af97e8b784fb972/tls.tf#L42
    name = "consul"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
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
  {
    name = "traefik"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = ["traefik.service.consul"]
      subject = {
        common_name  = "traefik.service.consul"
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
  {
    name = "minio"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = [
        "minio.service.consul",
        "localhost"
      ]
      subject = {
        common_name  = "minio.service.consul"
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
]
