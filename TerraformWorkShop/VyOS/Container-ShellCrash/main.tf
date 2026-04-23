resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
    data_dirs = "/mnt/data/shellcrash /mnt/data/shellcrash_cron"
  }
  connection {
    type     = "ssh"
    host     = self.triggers.host
    port     = self.triggers.port
    user     = self.triggers.user
    password = self.triggers.password
  }
  provisioner "remote-exec" {
    inline = [
      <<-EOT
        #!/bin/bash
        sudo mkdir -p ${self.triggers.data_dirs}
        sudo chown ${var.owner.uid}:${var.owner.gid} ${self.triggers.data_dirs}
      EOT
    ]
  }
  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [
  #     "sudo rm -rf ${self.triggers.data_dirs}",
  #   ]
  # }
}

module "config_map" {
  source = "../../modules/system-config_files"
  owner  = var.owner
  config = {
    create_dir = true
    dir        = "/mnt/data/shellcrash_cron"
    files = [
      {
        basename = "root"
        content  = <<-EOT
        EOT
        #  # do daily/weekly/monthly maintenance
        #  # min   hour    day     month   weekday command
        #  * * * * * test -z "$(pidof CrashCore)" && /bin/ash /etc/ShellCrash/starts/start_legacy_wd.sh shellcrash #ShellCrash保守模式守护进程
        mode = 600
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map.config,
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = true
    name        = "shellcrash"
    cidr_prefix = "172.16.50.0/24"
  }
  workloads = [
    {
      name      = "shellcrash"
      image     = "zot.vyos.sololab/juewuy/shellcrash:1.9.4release"
      pull_flag = "--tls-verify=false"
      # local_image = ""
      others = {
        "environment TZ value" = "Asia/Shanghai"
        # "allow-host-networks"  = ""
        "network shellcrash address"         = "172.16.50.10"
        "privileged"                         = ""
        "volume shellcrash_data source"      = "/mnt/data/shellcrash"
        "volume shellcrash_data destination" = "/etc/ShellCrash/configs"
        "volume shellcrash_cron source"      = "/mnt/data/shellcrash_cron"
        "volume shellcrash_cron destination" = "/etc/crontabs"
      }
    }
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend_console = {
      path = "load-balancing haproxy service tcp443 rule 50"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "shellcrash.vyos.sololab"
        "set backend" = "vyos_shellcrash_ssl"
      }
    }
    l4_backend_console = {
      path = "load-balancing haproxy backend vyos_shellcrash_ssl"
      configs = {
        "mode"                      = "tcp"
        "server shellcrash address" = "127.0.0.1"
        "server shellcrash port"    = "9999"
        # "server shellcrash send-proxy-v2" = ""
      }
    }
    l7_frontend_console = {
      path = "load-balancing haproxy service vyos_shellcrash_ssl"
      configs = {
        # "listen-address 127.0.0.1 accept-proxy" = ""
        "listen-address 127.0.0.1" = ""
        "port"                     = "9999"
        "mode"                     = "tcp"
        "backend"                  = "vyos_shellcrash"
        "ssl certificate"          = "vyos"
      }
    }
    l7_backend_console = {
      path = "load-balancing haproxy backend vyos_shellcrash"
      configs = {
        "mode"                 = "http"
        "server minio address" = "172.16.50.10"
        "server minio port"    = "9999"
      }
    }
    l4_frontend_proxy = {
      path = "load-balancing haproxy service tcp7890"
      configs = {
        "listen-address" = "192.168.255.1"
        "port"           = "7890"
        "mode"           = "tcp"
        "backend"        = "shellcrash"
      }
    }
    l4_backend_proxy = {
      path = "load-balancing haproxy backend shellcrash"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.50.10"
        "server vyos port"    = "7890"
        # "server vyos send-proxy-v2" = ""
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

resource "system_file" "consul_service" {
  depends_on = [null_resource.init]
  for_each = toset([
    "./attachments/shellcrash.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
