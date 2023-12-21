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
    bin_file_path   = "/usr/bin/consul"
  }
  config = {
    file_source = "./consul/consul.hcl"
    vars = {
      bind_addr       = "192.168.255.2"
      client_addr     = "192.168.255.2"
      data_dir        = "/mnt/data/consul"
      token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
    }
  }
  config_file_source = "./consul/consul.hcl"
  config_file_vars = {
    client_addr     = "192.168.255.2"
    data_dir        = "/mnt/data/consul"
    token_init_mgmt = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
  }
  config_file_vars_others = {
    bind_addr = "192.168.255.2"
  }
  systemd_file_source = "./consul/consul.service"
  systemd_file_vars = {
    user  = "vyos"
    group = "users"
  }
}

stepca_version  = "0.25.2"
stepcli_version = "0.25.1"
stepca_conf = {
  data_dir = "/mnt/data/step-ca"
  init = {
    name             = "sololab"
    acme             = true
    dns_names        = "localhost,step-ca.service.consul"
    ssh              = true
    remote_mgmt      = true
    provisioner_name = "admin"
  }
  password    = "P@ssw0rd"
  pwd_subpath = "password.txt"
}

traefik_version = "v2.10.7"

minio = {
  bin_file_source     = "https://dl.min.io/server/minio/release/linux-amd64/minio"
  config_file_source  = "./minio/minio.conf"
  systemd_file_source = "./minio/minio.service"
}
