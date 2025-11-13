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

# load secret from vault
data "vault_kv_secret_v2" "secret" {
  for_each = {
    for secret in [
      {
        mount = "kvv2-certs"
        name  = "client.global.nomad"
      },
      {
        mount = "kvv2-consul"
        name  = "token-nomad_client"
      },
      {
        mount = "kvv2-nomad"
        name  = "token-node_write"
      },
    ] : secret.name => secret
  }
  mount = each.value.mount
  name  = each.value.name
}

module "nomad" {
  depends_on = [
    null_resource.init,
  ]
  source = "../../modules/system-nomad"
  vm_conn = {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  install = [
    {
      zip_file_source = "https://dufs.day0.sololab/public/binaries/nomad_1.11.0_linux_amd64.zip"
      zip_file_path   = "/var/home/core/nomad_1.11.0_linux_amd64.zip"
      bin_file_name   = "nomad"
      bin_file_dir    = "/var/home/core/.local/bin"
    },
    {
      zip_file_source = "https://dufs.day0.sololab/public/binaries/nomad-driver-podman_0.6.3_linux_amd64.zip"
      zip_file_path   = "/var/home/core/nomad-driver-podman_0.6.3_linux_amd64.zip"
      bin_file_name   = "nomad-driver-podman"
      bin_file_dir    = "/var/home/core/.local/bin"
    },
  ]
}

module "config_files" {
  source = "../../modules/system-config_files"
  owner = {
    uid = 1000
    gid = 1000
  }
  config = {
    create_dir = true
    dir        = "/var/home/core/.local/etc/nomad.d"
    files = [
      {
        basename = "client.hcl"
        content = templatefile("./attachments/client.hcl", {
          servers              = "nomad.service.consul"
          data_dir             = "/var/mnt/data/nomad" # /var/home/podmgr/.local/opt/nomad/data
          plugin_dir           = "/var/home/core/.local/bin"
          ca_file              = "/var/home/core/.local/etc/nomad.d/tls/ca.pem"
          cert_file            = "/var/home/core/.local/etc/nomad.d/tls/client.pem"
          key_file             = "/var/home/core/.local/etc/nomad.d/tls/client-key.pem"
          podman_socket        = "unix:///run/podman/podman.sock"
          CONSUL_HTTP_ADDR     = "127.0.0.1:8501"
          CONSUL_HTTP_TOKEN    = data.vault_kv_secret_v2.secret["token-nomad_client"].data["token"]
          vault_server_address = "https://vault.service.consul:8200"
        })
      }
    ]
    secrets = [
      {
        sub_dir = "tls"
        files = [
          {
            basename = "ca.pem"
            content  = data.vault_kv_secret_v2.secret["client.global.nomad"].data["ca"]
          },
          {
            basename = "client.pem"
            content  = data.vault_kv_secret_v2.secret["client.global.nomad"].data["cert"]
          },
          {
            basename = "client-key.pem"
            content  = data.vault_kv_secret_v2.secret["client.global.nomad"].data["private_key"]
          }
        ]
      }
    ]
  }
}

module "systemd_unit" {
  depends_on = [
    module.nomad,
    module.config_files
  ]
  source = "../../modules/system-systemd_unit_user"
  vm_conn = {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  units = [
    {
      auto_start = {
        enabled   = true
        link_path = "/var/home/core/.config/systemd/user/default.target.wants/nomad-client.service"
      }
      file = {
        content = templatefile("./attachments/nomad-client.service", {
          bin_path           = "/var/home/core/.local/bin/nomad"
          config_file        = "/var/home/core/.local/etc/nomad.d/client.hcl"
          ExecStartPreNomad  = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://nomad.service.consul:4646/v1/status/leader"
          ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://127.0.0.1:8501/v1/catalog/services"
          NOMAD_ADDR         = "https://127.0.0.1:14646"
          NOMAD_TOKEN        = data.vault_kv_secret_v2.secret["token-node_write"].data["token"]
          NOMAD_CACERT       = "/var/home/core/.local/etc/nomad.d/tls/ca.pem"
          NOMAD_CLIENT_CERT  = "/var/home/core/.local/etc/nomad.d/tls/client.pem"
          NOMAD_CLIENT_KEY   = "/var/home/core/.local/etc/nomad.d/tls/client-key.pem"
        })
        path = "/var/home/core/.config/systemd/user/nomad-client.service"
      }
      status = "start"
    }
  ]
}
