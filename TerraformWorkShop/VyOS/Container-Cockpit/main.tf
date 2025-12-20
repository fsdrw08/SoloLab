data "terraform_remote_state" "cert" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  certs = [
    for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
    if cert.name == "wildcard.vyos"
  ]
}

module "config_map" {
  source = "../../modules/system-config_files"
  owner = {
    uid = 0
    gid = 0
  }
  config = {
    create_dir = true
    dir        = "/mnt/data/etc/cockpit"
    files = [
      #   {
      #     basename = "Corefile"
      #     content = templatefile("./attachments/Corefile.tftpl", {
      #       int_facing_addr = "192.168.255.1"
      #       int_facing_ns   = "192.168.255.10:53"
      #       ext_facing_addr = "192.168.255.2"
      #       ext_facing_ns   = "172.16.40.10:53"
      #       public_ns       = "119.29.29.29"
      #     })
      #   }
    ]
    secrets = [
      {
        sub_dir = "ws-certs.d"
        files = [
          {
            basename = "cockpit.crt"
            content  = local.certs.0["cert_pem_chain"]
          },
          {
            basename = "cockpit.key"
            content  = local.certs.0["key_pem"]
          }
        ]
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = true
    name        = "cockpit"
    cidr_prefix = "172.16.80.0/24"
  }
  workloads = [
    {
      name      = "cockpit"
      image     = "zot.vyos.sololab/cockpit/ws:351"
      pull_flag = "--tls-verify=false"
      others = {
        "environment TZ value" = "Asia/Shanghai"

        "network cockpit address" = "172.16.80.10"

        "volume cockpit_cert source"      = "/mnt/data/etc/cockpit/ws-certs.d"
        "volume cockpit_cert destination" = "/etc/cockpit/ws-certs.d"
      }
    }
  ]
}

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
  ]
  for_each = {
    l4_frontend = {
      path = "load-balancing haproxy service tcp443 rule 80"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "cockpit.vyos.sololab"
        "set backend" = "vyos_cockpit_ssl"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend vyos_cockpit_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos address" = "172.16.80.10"
        "server vyos port"    = "9090"
      }
    }
    # l7_frontend = {
    #   path = "load-balancing haproxy service vyos_cockpit_ssl"
    #   configs = {
    #     "listen-address"  = "127.0.0.1"
    #     "port"            = "9090"
    #     "mode"            = "tcp"
    #     "backend"         = "vyos_cockpit"
    #     "ssl certificate" = "vyos"
    #   }
    # }
    # l7_backend = {
    #   path = "load-balancing haproxy backend vyos_cockpit"
    #   configs = {
    #     "mode"                = "http"
    #     "server vyos address" = "172.16.80.10"
    #     "server vyos port"    = "9090"
    #   }
    # }
  }
  path    = each.value.path
  configs = each.value.configs
}

resource "vyos_config_block_tree" "snat" {
  path = "nat source rule 10"
  configs = {
    "description"             = "cockpit"
    "outbound-interface name" = "eth1"
    "source address"          = "172.16.80.0/24"
    "translation address"     = "masquerade"
  }
}

resource "system_file" "consul_service" {
  for_each = toset([
    "./attachments/cockpit.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
