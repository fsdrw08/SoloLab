module "coredns" {
  source = "../modules/coredns"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    tar_file_source = "https://github.com/coredns/coredns/releases/download/v1.11.1/coredns_1.11.1_linux_amd64.tgz"
    tar_file_path   = "/home/vyos/coredns_1.11.1_linux_arm64.tgz"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    take_charge = false
    user        = "vyos"
    group       = "users"
  }
  config = {
    corefile = {
      content = templatefile("${path.root}/coredns/Corefile", {
        listen_address = "192.168.255.2"
        import         = "/etc/coredns/snippets/*.conf"
        forward        = ". 127.0.0.1:8600"
      })
    }
    snippets = {
      sub_dir = "snippets"
      # files = [
      #   {
      #     basename = "consul.db"
      #     content = templatefile("${path.root}/coredns/consul.db", {

      #     })
      #   }
      # ]
    }
    dir = "/etc/coredns"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_service_unit = {
      content = templatefile("${path.root}/coredns/coredns.service", {
        user  = "vyos"
        group = "users"
      })
      path = "/etc/systemd/system/coredns.service"
    }
  }
}

module "coredns_restart" {
  depends_on = [module.sws]
  source     = "../modules/systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    path = "/etc/systemd/system/coredns_restart.path"
    content = templatefile("${path.root}/coredns/restart.path", {
      PathModified = [
        "/etc/coredns/Corefile",
      ]
      PathExistsGlob = [
        "/etc/coredns/snippets/*.conf"
      ]
    })
  }
  systemd_service_unit = {
    path = "/etc/systemd/system/coredns_restart.service"
    content = templatefile("${path.root}/coredns/restart.service", {
      AssertPathExists = "/etc/systemd/system/coredns.service"
      target_service   = "coredns.service"
    })
  }
}
