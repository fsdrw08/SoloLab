resource "null_resource" "nomad_init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    dirs        = "/var/home/core/.local/bin /var/home/core/nomad.d/data"
    chown_user  = "core"
    chown_group = "core"
    chown_dir   = "/var/home/core/nomad.d/data"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/nomad/init.sh", {
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
  install = {
    zip_file_source = "http://dufs.day0.sololab/bin/nomad_1.10.3_linux_amd64.zip"
    zip_file_path   = "/var/home/core/nomad_1.10.3_linux_amd64.zip"
    bin_file_dir    = "/var/home/core/.local/bin"
  }
  config = {
    main = {
      basename = "client.hcl"
      content = templatefile("./nomad/client.hcl", {
        servers   = "nomad.day1.sololab"
        data_dir  = "/var/home/core/nomad.d/data"
        ca_file   = "/var/home/core/nomad.d/tls/ca.pem"
        cert_file = "/var/home/core/nomad.d/tls/client.pem"
        key_file  = "/var/home/core/nomad.d/tls/client-key.pem"
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
    dir        = "/var/home/core/nomad.d"
    create_dir = false
  }
  service = {
    status  = "start"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/nomad/nomad-client.service", {
        user        = "core"
        group       = "core"
        bin_path    = "/var/home/core/.local/bin/nomad"
        config_file = "/var/home/core/nomad.d/client.hcl"
      })
      path = "/var/home/core/.config/systemd/user/nomad.service"
    }
  }
}
