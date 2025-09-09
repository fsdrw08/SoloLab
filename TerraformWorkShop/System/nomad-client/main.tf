resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    rootless_dirs    = "/var/home/core/.local/bin,/var/home/core/.local/etc" # "/var/home/podmgr/.local/bin,/var/home/podmgr/.local/etc,/var/home/podmgr/.local/opt/nomad/data"
    root_dirs        = "/var/mnt/data/nomad"
    root_chown_dirs  = "/var/mnt/data/nomad"
    root_chown_user  = "root"
    root_chown_group = "root"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/attachments/init.sh", {
        rootless_dirs    = split(",", self.triggers.rootless_dirs)
        root_dirs        = split(",", self.triggers.root_dirs)
        root_chown_dirs  = split(",", self.triggers.root_chown_dirs)
        root_chown_user  = self.triggers.root_chown_user
        root_chown_group = self.triggers.root_chown_group
      })
    ]
  }
}

# load cert from vault
data "vault_kv_secret_v2" "cert" {
  mount = "kvv2-certs"
  name  = "client.global.nomad"
}

data "vault_kv_secret_v2" "consul_token" {
  mount = "kvv2-consul"
  name  = "token-nomad_client"
}

data "vault_kv_secret_v2" "nomad_token" {
  mount = "kvv2-nomad"
  name  = "token-node_write"
}

resource "system_systemd_unit" "podman_socket" {
  type    = "socket"
  name    = "podman"
  enabled = true
  status  = "started"
}

module "nomad" {
  depends_on = [
    null_resource.init,
    system_systemd_unit.podman_socket
  ]
  source = "../../modules/system-nomad"
  vm_conn = {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  runas = {
    take_charge = false
    user        = "core"
    uid         = "1000"
    group       = "core"
    gid         = "1000"
  }
  install = [
    {
      zip_file_source = "http://dufs.day0.sololab/binaries/nomad_1.10.4_linux_amd64.zip"
      zip_file_path   = "/var/home/core/nomad_1.10.4_linux_amd64.zip"
      bin_file_name   = "nomad"
      bin_file_dir    = "/var/home/core/.local/bin"
    },
    {
      zip_file_source = "http://dufs.day0.sololab/binaries/nomad-driver-podman_0.6.3_linux_amd64.zip"
      zip_file_path   = "/var/home/core/nomad-driver-podman_0.6.3_linux_amd64.zip"
      bin_file_name   = "nomad-driver-podman"
      bin_file_dir    = "/var/home/core/.local/bin"
    },
  ]
  config = {
    main = {
      basename = "client.hcl"
      content = templatefile("./attachments/client.hcl", {
        servers              = "nomad.day1.sololab"
        data_dir             = "/var/mnt/data/nomad" # /var/home/podmgr/.local/opt/nomad/data
        plugin_dir           = "/var/home/core/.local/bin"
        ca_file              = "/var/home/core/.local/etc/nomad.d/tls/ca.pem"
        cert_file            = "/var/home/core/.local/etc/nomad.d/tls/client.pem"
        key_file             = "/var/home/core/.local/etc/nomad.d/tls/client-key.pem"
        podman_socket        = "unix:///run/podman/podman.sock"
        CONSUL_HTTP_ADDR     = "127.0.0.1:8501"
        CONSUL_HTTP_TOKEN    = data.vault_kv_secret_v2.consul_token.data["token"]
        vault_server_address = "https://vault.service.consul:8200"
      })
    }
    tls = {
      sub_dir       = "tls"
      ca_basename   = "ca.pem"
      ca_content    = data.vault_kv_secret_v2.cert.data["ca"]
      cert_basename = "client.pem"
      cert_content  = data.vault_kv_secret_v2.cert.data["cert"]
      key_basename  = "client-key.pem"
      key_content   = data.vault_kv_secret_v2.cert.data["private_key"]
    }
    dir        = "/var/home/core/.local/etc/nomad.d"
    create_dir = true
  }
  service = {
    status = "start"
    auto_start = {
      enabled     = true
      link_path   = "/var/home/core/.config/systemd/user/default.target.wants/nomad-client.service"
      link_target = "/var/home/core/.config/systemd/user/nomad-client.service"
    }
    systemd_service_unit = {
      content = templatefile("${path.root}/attachments/nomad-client.service", {
        bin_path           = "/var/home/core/.local/bin/nomad"
        config_file        = "/var/home/core/.local/etc/nomad.d/client.hcl"
        ExecStartPreNomad  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://nomad.day1.sololab:4646/v1/status/leader"
        ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://127.0.0.1:8501/v1/catalog/services"
        NOMAD_ADDR         = "https://127.0.0.1:14646"
        NOMAD_TOKEN        = data.vault_kv_secret_v2.nomad_token.data["token"]
        NOMAD_CACERT       = "/var/home/core/.local/etc/nomad.d/tls/ca.pem"
        NOMAD_CLIENT_CERT  = "/var/home/core/.local/etc/nomad.d/tls/client.pem"
        NOMAD_CLIENT_KEY   = "/var/home/core/.local/etc/nomad.d/tls/client-key.pem"
      })
      path = "/var/home/core/.config/systemd/user/nomad-client.service"
    }
  }
}
