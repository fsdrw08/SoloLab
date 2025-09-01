resource "null_resource" "nomad_init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    dirs        = "/var/home/core/.local/bin /var/mnt/data/nomad"
    chown_user  = "root"
    chown_group = "root"
    chown_dir   = "/var/mnt/data/nomad"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/attachments/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

# load cert from vault
data "vault_kv_secret_v2" "cert" {
  mount = "kvv2-certs"
  name  = "client.global.nomad"
}

data "vault_kv_secret_v2" "token" {
  mount = "kvv2-consul"
  name  = "token-nomad_client"
}

module "nomad" {
  depends_on = [null_resource.nomad_init]
  source     = "../../modules/system-nomad"
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
        servers                = "nomad.day1.sololab"
        vault_server_address   = "https://vault.service.consul:8200"
        nomad_consul_acl_token = data.vault_kv_secret_v2.token.data["token"]
        data_dir               = "/var/home/core/.local/etc/nomad.d/data"
        plugin_dir             = "/var/home/core/.local/bin"
        ca_file                = "/var/home/core/.local/etc/nomad.d/tls/ca.pem"
        cert_file              = "/var/home/core/.local/etc/nomad.d/tls/client.pem"
        key_file               = "/var/home/core/.local/etc/nomad.d/tls/client-key.pem"
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
    dir        = "/var/mnt/data/nomad"
    create_dir = false
  }
  service = {
    status  = "start"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/attachments/nomad-client.service", {
        user        = "core"
        group       = "core"
        bin_path    = "/var/home/core/.local/bin/nomad"
        config_file = "/var/home/core/.local/nomad.d/client.hcl"
      })
      path = "/var/home/core/.config/systemd/user/nomad.service"
    }
  }
}
