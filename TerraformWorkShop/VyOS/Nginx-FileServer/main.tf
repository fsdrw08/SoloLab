resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/offline"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/offline"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/nginx/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

module "nginx_restart" {
  source = "../../System/modules/systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    content = templatefile("${path.module}/nginx/restart.path", {
      PathModified = []
      PathChanged = [
        "/etc/nginx/conf.d"
      ]
    })
    path = "/lib/systemd/system/nginx_restart.path"
  }
  systemd_service_unit = {
    content = templatefile("${path.module}/nginx/restart.service", {
      AssertPathExists = "/lib/systemd/system/nginx.service"
      target_service   = "nginx.service"
    })
    path = "/lib/systemd/system/nginx_restart.service"
  }
}

resource "system_file" "config" {
  depends_on = [
    module.nginx_restart
  ]
  path = "/etc/nginx/conf.d/fileserver.conf"
  content = templatefile("${path.module}/nginx/fileserver.conf", {
    listen      = "192.168.255.1:8080"
    server_name = "files.mgmt.sololab"
    root        = "/mnt/data/offline"
  })
  user  = "vyos"
  group = "users"
  mode  = "644"
}

resource "vyos_static_host_mapping" "files" {
  host = "files.mgmt.sololab"
  ip   = "192.168.255.1"
}

# https://serverfault.com/questions/1078467/how-to-force-a-specific-routing-based-on-sni-in-haproxy/1078563#1078563
resource "vyos_config_block_tree" "lb_svc_http_files" {
  path = "load-balancing reverse-proxy service http rule 10"
  configs = {
    "domain-name" = "files.mgmt.sololab"
    "set backend" = "files"
  }
}

resource "vyos_config_block_tree" "lb_be_files" {
  path = "load-balancing reverse-proxy backend files"
  configs = {
    "mode"                = "http"
    "server vyos address" = "192.168.255.1"
    "server vyos port"    = "8080"
  }
}
