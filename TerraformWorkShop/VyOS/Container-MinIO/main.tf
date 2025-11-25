resource "null_resource" "init" {
  triggers = {
    host      = var.prov_system.host
    port      = var.prov_system.port
    user      = var.prov_system.user
    password  = var.prov_system.password
    uid       = var.owner.uid
    gid       = var.owner.gid
    data_dirs = "/mnt/data/minio"
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
    dir        = "/mnt/data/etc/minio"
    files = [
      {
        basename = "config.env"
        # https://docs.min.io/community/minio-object-store/reference/minio-server/settings/console.html#browser-redirect-url
        content = <<-EOT
          MINIO_ROOT_USER=minioadmin
          MINIO_ROOT_PASSWORD=minioadmin
          MINIO_UPDATE=off
          MINIO_VOLUMES=/data
          MINIO_PROMETHEUS_AUTH_TYPE=public
        EOT
        mode    = 644
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
    null_resource.init,
    module.config_map,
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = true
    name        = "minio"
    cidr_prefix = "172.16.70.0/24"
  }
  workloads = [
    {
      name      = "minio"
      image     = "zot.vyos.sololab/minio/minio:RELEASE.2025-09-07T16-13-09Z"
      pull_flag = "--tls-verify=false"
      # local_image = ""
      others = {
        "arguments"                               = "server --address=:9000 --console-address=:9001"
        "environment TZ value"                    = "Asia/Shanghai"
        "environment MINIO_CONFIG_ENV_FILE value" = "/etc/config.env"
        "network minio address"                   = "172.16.70.10"

        "volume minio_config source"      = "/mnt/data/etc/minio/config.env"
        "volume minio_config destination" = "/etc/config.env"
        "volume minio_data source"        = "/mnt/data/minio"
        "volume minio_data destination"   = "/data"
      }
    }
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend_api = {
      path = "load-balancing haproxy service tcp443 rule 70"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "minio-api.vyos.sololab"
        "set backend" = "vyos_minio_ssl"
      }
    }
    l4_backend_api = {
      path = "load-balancing haproxy backend vyos_minio_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "9000"
      }
    }
    l7_frontend_api = {
      path = "load-balancing haproxy service vyos_minio_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "9000"
        "mode"            = "tcp"
        "backend"         = "vyos_minio"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend_api = {
      path = "load-balancing haproxy backend vyos_minio"
      configs = {
        "mode"                 = "http"
        "server minio address" = "172.16.70.10"
        "server minio port"    = "9000"
      }
    }
    l4_frontend_console = {
      path = "load-balancing haproxy service tcp443 rule 75"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "minio-console.vyos.sololab"
        "set backend" = "vyos_mc_ssl"
      }
    }
    l4_backend_console = {
      path = "load-balancing haproxy backend vyos_mc_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "9001"
      }
    }
    l7_frontend_console = {
      path = "load-balancing haproxy service vyos_mc_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "9001"
        "mode"            = "tcp"
        "backend"         = "vyos_mc"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend_console = {
      path = "load-balancing haproxy backend vyos_mc"
      configs = {
        "mode"                 = "http"
        "server minio address" = "172.16.70.10"
        "server minio port"    = "9001"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

resource "system_file" "consul_service" {
  depends_on = [null_resource.init]
  for_each = toset([
    "./attachments/minio.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
