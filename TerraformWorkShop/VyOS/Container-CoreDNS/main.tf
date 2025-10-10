data "terraform_remote_state" "cert" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  certs = [
    for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
    if cert.name == "doh.vyos"
  ]
}

module "config_map" {
  source = "../../modules/system-config_files"
  owner = {
    uid = 1002
    gid = 100
  }
  config = {
    create_dir = true
    dir        = "/mnt/data/etc/coredns"
    files = [
      {
        basename = "Corefile"
        content = templatefile("./attachments/Corefile.tftpl", {
          int_facing_addr       = "192.168.255.1"
          int_facing_ns_sololab = "192.168.255.10:53"
          int_facing_ns_consul  = "192.168.255.20:53"
          ext_facing_addr       = "192.168.255.2"
          ext_facing_ns         = "172.16.40.10:53"
          public_ns             = "119.29.29.29"
        })
      },
      {
        basename = "vyos.sololab.zone"
        content  = file("./attachments/vyos.sololab.zone")
      }
    ]
    secrets = [
      {
        sub_dir = "tls"
        files = [
          {
            basename = "cert.pem"
            content  = local.certs.0["cert_pem_chain"]
          },
          {
            basename = "key.pem"
            content  = local.certs.0["key_pem"]
          }
        ]
      }
    ]
  }
}

module "vyos_container" {
  depends_on = [
    module.config_map
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  workloads = [
    {
      name      = "coredns"
      image     = "172.16.20.10:5000/coredns/coredns:1.12.4"
      pull_flag = "--tls-verify=false"
      others = {
        "allow-host-networks"  = ""
        "arguments"            = "-conf /etc/coredns/Corefile"
        "uid"                  = 1002
        "gid"                  = 100
        "environment TZ value" = "Asia/Shanghai"

        "volume coredns source"      = "/mnt/data/etc/coredns"
        "volume coredns destination" = "/etc/coredns"
      }
    }
  ]
}

# resource "vyos_config_block_tree" "pki" {
#   path = "pki certificate coredns.vyos"
#   configs = {
#     "certificate" = join("",
#       slice(
#         split("\n", local.certs.0["cert_pem"]),
#         1,
#         length(
#           split("\n", local.certs.0["cert_pem"])
#         ) - 2
#       )
#     )
#     "private key" = join("",
#       slice(
#         split("\n", local.certs.0["key_pkcs8"]),
#         1,
#         length(
#           split("\n", local.certs.0["key_pkcs8"])
#         ) - 2
#       )
#     )
#   }
# }

resource "vyos_config_block_tree" "reverse_proxy" {
  depends_on = [
    module.vyos_container,
    # vyos_config_block_tree.pki
  ]
  for_each = {
    l4_frontend = {
      # when send doh request to doh server by ip address,
      # it means no SNI information in the tcp request,
      # have to set default backend for this kind of request in haproxy
      # update: use public dns recode to point to private ip instead
      path = "load-balancing haproxy service tcp443 rule 30"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "doh.sololab.dev"
        "set backend" = "vyos_coredns"
      }
    }
    l4_backend = {
      path = "load-balancing haproxy backend vyos_coredns"
      configs = {
        "mode"                = "tcp"
        "server vyos port"    = "44353"
        "server vyos address" = "127.0.0.1"
      }
    }
    l4_frontend_metrics = {
      path = "load-balancing haproxy service tcp443 rule 35"
      configs = {
        "ssl"         = "req-ssl-sni"
        "domain-name" = "coredns.vyos.sololab"
        "set backend" = "vyos_coredns_metrics_ssl"
      }
    }
    l4_backend_metrics = {
      path = "load-balancing haproxy backend vyos_coredns_metrics_ssl"
      configs = {
        "mode"                = "tcp"
        "server vyos port"    = "19153"
        "server vyos address" = "127.0.0.1"
      }
    }
    l7_frontend_metrics = {
      path = "load-balancing haproxy service vyos_coredns_metrics_ssl"
      configs = {
        "listen-address"  = "127.0.0.1"
        "port"            = "19153"
        "mode"            = "tcp"
        "backend"         = "vyos_coredns_metrics"
        "ssl certificate" = "vyos"
      }
    }
    l7_backend_metrics = {
      path = "load-balancing haproxy backend vyos_coredns_metrics"
      configs = {
        "mode"                = "http"
        "server vyos address" = "127.0.0.1"
        "server vyos port"    = "9153"
      }
    }
  }
  path    = each.value.path
  configs = each.value.configs
}

resource "vyos_config_block_tree" "dns_forwarding" {
  depends_on = [
    module.vyos_container,
  ]
  path = "service dns forwarding domain"
  configs = {
    "sololab name-server 127.0.0.1 port" = "53"
    "consul name-server 127.0.0.1 port"  = "53"
  }
}

resource "system_file" "consul_service" {
  for_each = toset([
    "./attachments/coredns.consul.hcl",
  ])
  path    = "/mnt/data/consul-services/${basename(each.key)}"
  content = file("${each.key}")
}
