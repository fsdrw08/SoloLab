vm_conn = {
  host     = "192.168.255.1"
  port     = 22
  user     = "vyos"
  password = "vyos"
}

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
      client_addr     = "192.168.255.2"
      data_dir        = "/opt/consul"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
    file_path_dir = "/etc/consul.d"
  }
  service = {
    status  = "started"
    enabled = true
    systemd = {
      file_source = "./consul/consul.service"
      file_path   = "/etc/systemd/system/consul.service"
      vars = {
        user  = "vyos"
        group = "users"
      }
    }
  }
}

stepca = {
  install = {
    tar_file_source = "https://dl.smallstep.com/certificates/docs-ca-install/latest/step-ca_linux_amd64.tar.gz"
    tar_file_path   = "/home/vyos/step-ca_linux_amd64.tar.gz"
    bin_file_dir    = "/usr/bin"
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

traefik_version = "v2.10.7"

minio = {
  bin_file_source     = "https://dl.min.io/server/minio/release/linux-amd64/minio"
  config_file_source  = "./minio/minio.conf"
  systemd_file_source = "./minio/minio.service"
}
