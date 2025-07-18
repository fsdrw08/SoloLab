resource "null_resource" "nomad_init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    dirs        = "/var/home/core/nomad/data"
    chown_user  = "core"
    chown_group = "core"
    chown_dir   = "/var/home/core/nomad/data"
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

module "nomad" {
  source = "../../modules/system-nomad_client"
  vm_conn = {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  runas = {
    take_charge = false
    user        = "core"
    group       = "core"
  }
  install = {
    zip_file_source = "http://dufs.day0.sololab/bin/nomad_1.10.3_linux_amd64.zip"
    zip_file_path   = "/var/home/core/nomad_1.10.3_linux_amd64.zip"
    bin_file_dir    = "/var/home/core/nomad"
  }
  config = {
    main = {
      basename = "client.hcl"
      content = templatefile("./nomad/client.hcl", {
        NOMAD_SERVERS  = "nomad.day0.sololab"
        NOMAD_DATA_DIR = "/var/home/core/nomad/data"
      })
    }
    dir = "/var/home/core/nomad"
  }
  service = {
    status  = "start"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/nomad/nomad-client.service", {
        user        = "core"
        group       = "core"
        bin_path    = "/var/home/core/nomad/nomad"
        config_file = "/var/home/core/nomad/client.hcl"
      })
      path = "/var/home/core/.config/systemd/user/nomad.service"
    }
  }
}
