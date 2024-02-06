vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

tftp = {
  address = "192.168.255.1"
  dir = {
    path = "/mnt/data/tftp"
    own_by = {
      user  = "vyos"
      group = "users"
    }
  }
}

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
      postal_code         = ""
      province            = "GD"
      serial_number       = ""
      street_address      = ""
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
    name = "vault"
    key = {
      algorithm = "RSA"
      rsa_bits  = 4096
    }
    cert = {
      dns_names = ["vault.service.consul"]
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
      dir = "/opt/vault/tls"
    }
  }
]

consul = {
  install = {
    zip_file_source = "https://releases.hashicorp.com/consul/1.17.0/consul_1.17.0_linux_amd64.zip"
    zip_file_path   = "/home/vyos/consul.zip"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  storage = {
    dir_target = "/mnt/data/consul"
    dir_link   = "/opt/consul"
  }
  config = {
    file_source = "./consul/consul.hcl"
    vars = {
      bind_addr       = "192.168.255.2"
      dns_addr        = "192.168.255.2"
      client_addr     = "127.0.0.1"
      data_dir        = "/opt/consul"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
    file_path_dir = "/etc/consul.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      file_source = "./consul/consul.service"
      vars = {
        user  = "vyos"
        group = "users"
      }
      file_path = "/etc/systemd/system/consul.service"
    }
  }
}

consul_post_process = {
  Config-ConsulDNS = {
    script_path = "./consul/Config-ConsulDNS.sh"
    vars = {
      client_addr     = "127.0.0.1:8500"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
  }
  Update-vyOSDNS = {
    script_path = "./consul/Update-vyOSDNS.sh"
    vars = {
      domain = "consul"
      ip     = "192.168.255.2"
    }
  }
}


vault = {
  install = {
    zip_file_source = "https://releases.hashicorp.com/vault/1.15.5/vault_1.15.5_linux_amd64.zip"
    zip_file_path   = "/home/vyos/vault.zip"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  storage = {
    dir_target = "/mnt/data/vault"
    dir_link   = "/opt/vault"
  }
  config = {
    file_source = "./vault/vault.hcl"
    vars = {
      bind_addr       = "192.168.255.2"
      dns_addr        = "192.168.255.2"
      client_addr     = "127.0.0.1"
      data_dir        = "/opt/vault"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
    file_path_dir = "/etc/vault.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      file_source = "./vault/vault.service"
      vars = {
        user  = "vyos"
        group = "users"
      }
      file_path = "/etc/systemd/system/consul.service"
    }
  }
}


stepca = {
  install = {
    server = {
      tar_file_source   = "https://dl.smallstep.com/gh-release/certificates/gh-release-header/v0.25.2/step-ca_linux_0.25.2_amd64.tar.gz"
      tar_file_path     = "/home/vyos/step-ca_linux_amd64.tar.gz"
      tar_file_bin_path = "step-ca"
      bin_file_dir      = "/usr/bin"
    }
    client = {
      tar_file_source   = "https://dl.smallstep.com/gh-release/cli/gh-release-header/v0.25.2/step_linux_0.25.2_amd64.tar.gz"
      tar_file_path     = "/home/vyos/step_linux_amd64.tar.gz"
      tar_file_bin_path = "step_0.25.2/bin/step"
      bin_file_dir      = "/usr/bin"
    }
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  storage = {
    dir_target = "/mnt/data/step-ca"
    dir_link   = "/etc/step-ca"
  }
  config = {
    file_source = "./step-ca/step-ca.env"
    vars = {
      STEPPATH               = "/etc/step-ca"
      PWD_SUBPATH            = "password.txt"
      INIT_ADDRESS           = "192.168.255.2:8443"
      INIT_NAME              = "sololab"
      INIT_ACME              = true
      INIT_DNS_NAMES         = "localhost,step-ca.service.consul"
      INIT_SSH               = true
      INIT_REMOTE_MANAGEMENT = true
      INIT_PROVISIONER_NAME  = "admin"
      INIT_PASSWORD          = "P@ssw0rd"
    }
    file_path_dir = "/home/vyos"
  }
  init_script = {
    file_source = "./step-ca/entrypoint.sh"
  }
  service = {
    status  = "started"
    enabled = true
    systemd = {
      file_source = "./step-ca/step-ca.service"
      vars = {
        user  = "vyos"
        group = "users"
      }
      file_path = "/etc/systemd/system/step-ca.service"
    }
  }
}

traefik = {
  install = {
    tar_file_source = "https://github.com/traefik/traefik/releases/download/v2.10.7/traefik_v2.10.7_linux_amd64.tar.gz"
    tar_file_path   = "/home/vyos/traefik.tar.gz"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  config = {
    static = {
      file_source = "./traefik/traefik.yaml"
      vars = {
        consul_client_addr   = "127.0.0.1:8500"
        consul_datacenter    = "dc1"
        rootCA               = "/etc/step-ca/certs/root_ca.crt"
        entrypoint_traefik   = "192.168.255.2:8080"
        entrypoint_web       = "192.168.255.2:80"
        entrypoint_websecure = "192.168.255.2:443"
        acme_ext_storage     = "/etc/traefik/acme/external.json"
        acme_int_caserver    = "https://step-ca.service.consul:8443/acme/acme/directory"
        acme_int_storage     = "/etc/traefik/acme/internal.json"
        access_log_path      = "/mnt/data/traefik/access.log"
      }
      file_path_dir = "/etc/traefik"
    }
    dynamic = {
      file_contents = [
        {
          file_source = "./traefik/dyn-traefik_dashboard.yaml"
          vars = {
            sub_domain  = "traefik"
            base_domain = "service.consul"
            userpass    = "admin:$apr1$/F5ai.wT$7nFJWh4F7ZA0qoY.JZ69l1"
          }
        },
        {
          file_source = "./traefik/dyn-toHttps.yaml"
          vars = {
            permanent = "true"
          }
        },
      ]
      file_path_dir = "/etc/traefik/dynamic"
    }
  }
  storage = {
    dir_target = "/mnt/data/traefik"
    dir_link   = "/etc/traefik/acme"
  }
  service = {
    traefik_restart = {
      status  = "started"
      enabled = true
      systemd_unit_service = {
        file_source = "./traefik/traefik_restart.service"
        vars = {
          traefik_service_file = "/etc/systemd/system/traefik.service"
        }
        file_path = "/etc/systemd/system/traefik_restart.service"
      }
      systemd_unit_path = {
        file_source = "./traefik/traefik_restart.path"
        vars = {
          static_config_path = "/etc/traefik/traefik.yaml"
        }
        file_path = "/etc/systemd/system/traefik_restart.path"
      }
    }
    traefik = {
      status  = "started"
      enabled = true
      systemd_unit_service = {
        file_source = "./traefik/traefik.service"
        vars = {
          user                 = "vyos"
          group                = "users"
          LEGO_CA_CERTIFICATES = "/etc/step-ca/certs/root_ca.crt"
        }
        file_path = "/etc/systemd/system/traefik.service"
      }
    }
  }
}


minio = {
  install = {
    server = {
      bin_file_source = "https://dl.min.io/server/minio/release/linux-amd64/minio"
      bin_file_dir    = "/usr/local/bin"
    }
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  storage = {
    dir_target = "/mnt/data/minio"
  }
  config = {
    file_source = "./minio/minio.conf"
    vars = {
      MINIO_OPTS                 = <<EOT
      --address 127.0.0.1:9000 \
      --console-address 127.0.0.1:9001 \
      --certs-dir /opt/minio_certs
      EOT
      MINIO_VOLUMES              = "/mnt/data/minio"
      MINIO_SERVER_URL           = "https://minio.service.consul"
      MINIO_BROWSER_REDIRECT_URL = "https://minio.service.consul/ui"
      MINIO_ROOT_USER            = "admin"
      MINIO_ROOT_PASSWORD        = "P@ssw0rd"
    }
    file_path = "/etc/default/minio"
  }
  service = {
    minio_restart = {
      status  = "started"
      enabled = true
      systemd_unit_service = {
        file_source = "./minio/minio_restart.service"
        vars = {
          minio_service_file = "/usr/lib/systemd/system/minio.service"
        }
        file_path = "/usr/lib/systemd/system/minio_restart.service"
      }
      systemd_unit_path = {
        file_source = "./minio/minio_restart.path"
        vars = {
          config_path = "/etc/default/minio"
        }
        file_path = "/usr/lib/systemd/system/minio_restart.path"
      }
    }
    minio = {
      status  = "started"
      enabled = true
      systemd_unit_service = {
        file_source = "./minio/minio.service"
        vars = {
          user  = "vyos"
          group = "users"
        }
        file_path = "/usr/lib/systemd/system/minio.service"
      }
    }
  }
}

minio_certs = {
  dir            = "/opt/minio_certs"
  CAs_dir_link   = "/opt/minio_certs/CAs"
  CAs_dir_target = "/etc/step-ca/certs"
}

sws = {
  install = {
    tar_file_source   = "https://github.com/static-web-server/static-web-server/releases/download/v2.25.0/static-web-server-v2.25.0-x86_64-unknown-linux-gnu.tar.gz"
    tar_file_path     = "/home/vyos/static-web-server-v2.25.0-x86_64-unknown-linux-gnu.tar.gz"
    tar_file_bin_path = "static-web-server-v2.25.0-x86_64-unknown-linux-gnu/static-web-server"
    bin_file_dir      = "/usr/local/bin"
  }
  storage = {
    dir_target = "/mnt/data/sws"
  }
  config = {
    file_source = "./sws/static-web-server_non_socket.toml"
    vars = {
      SERVER_HOST                    = "127.0.0.1"
      SERVER_PORT                    = "80"
      SERVER_ROOT                    = "/mnt/data/sws"
      SERVER_LOG_LEVEL               = "warn"
      SERVER_DIRECTORY_LISTING       = "true"
      SERVER_DIRECTORY_LISTING_ORDER = "0"
      VIRTUAL_HOST                   = "sws.service.consul"
      VIRTUAL_HOST_ROOT              = "/mnt/data/sws/bin"
    }
    file_path_dir = "/etc/static-web-server"
  }
  runas = {
    user  = "vyos"
    group = "users"
  }
  service = {
    sws = {
      status  = "started"
      enabled = true
      systemd_unit_service = {
        file_source = "./sws/static-web-server_non_socket.service"
        vars = {
          user               = "vyos"
          group              = "users"
          SERVER_CONFIG_FILE = "/etc/static-web-server/static-web-server_non_socket.toml"
        }
        file_path = "/etc/systemd/system/static-web-server.service"
      }
      # systemd_unit_socket = {
      #   file_source = "./sws/static-web-server.socket"
      #   vars = {
      #     ListenStream = "127.0.0.1:80"
      #   }
      #   file_path = "/etc/systemd/system/static-web-server.socket"
      # }
    }
    # sws_restart = {
    #   status  = "started"
    #   enabled = true
    #   systemd_unit_service = {
    #     file_source = "./sws/static-web-server_restart.service"
    #     vars = {
    #       SERVER_CONFIG_FILE  = "/etc/static-web-server/static-web-server.toml"
    #       TARGET_SERVICE_NAME = "static-web-server.service"
    #     }
    #     file_path = "/etc/systemd/system/static-web-server_restart.service"
    #   }
    #   systemd_unit_path = {
    #     file_source = "./SWS/static-web-server_restart.path"
    #     vars = {
    #       SERVER_CONFIG_FILE = "/etc/static-web-server/static-web-server.toml"
    #     }
    #     file_path = "/etc/systemd/system/static-web-server_restart.path"
    #   }
    # }
  }
}
