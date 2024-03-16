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
        listen_address     = "192.168.255.2"
        zone_dir           = "/etc/coredns/zones"
        default_forward_ip = "192.168.255.1"
      })
    }
    zones = {
      sub_dir = "zones"
    }
    dir = "/etc/coredns"
  }
  service = {
    status  = "started"
    enabled = true
    systemd_unit_service = {
      content = templatefile("${path.root}/coredns/coredns.service", {
        user  = "vyos"
        group = "users"
      })
      target_path = "/etc/systemd/system/coredns.service"
    }
  }
}
