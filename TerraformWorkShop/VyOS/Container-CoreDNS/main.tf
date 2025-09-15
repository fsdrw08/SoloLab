data "terraform_remote_state" "cert" {
  backend = "local"
  config = {
    path = "../../TLS/RootCA/terraform.tfstate"
  }
}

locals {
  certs = [
    for cert in data.terraform_remote_state.cert.outputs.signed_certs : cert
    if cert.name == "coredns.vyos"
  ]
}

module "config_map" {
  source  = "../../modules/system-coredns"
  vm_conn = var.prov_system
  install = null
  runas = {
    take_charge = false
    user        = "vyos"
    uid         = 1002
    group       = "users"
    gid         = 100
  }
  config = {
    create_dir = true
    dir        = "/etc/coredns"
    main = {
      basename = "Corefile"
      content  = <<-EOT
      (common) {
        reload 2s
        log
      }
      https://.:44353 {
        bind 127.0.0.1
        tls /etc/coredns/tls/cert.pem /etc/coredns/tls/key.pem
        forward sololab 172.16.2.10:1053
        forward . 192.168.255.1
        import common
      }
      EOT
    }
    tls = {
      cert_basename = "cert.pem"
      cert_content  = local.certs.0["cert_pem_chain"]
      key_basename  = "key.pem"
      key_content   = local.certs.0["key_pem"]
      sub_dir       = "tls"
    }
  }
}

module "vyos_container" {
  depends_on = [
    module.config_map
  ]
  source  = "../../modules/vyos-container"
  vm_conn = var.prov_system
  network = {
    create      = false
    name        = "coredns"
    cidr_prefix = "172.16.3.0/24"
    address     = "172.16.3.10"
  }
  workload = {
    name      = "coredns"
    image     = "zot.day0.sololab/coredns/coredns:1.12.4"
    pull_flag = "--tls-verify=false"
    others = {
      "allow-host-networks"  = ""
      "arguments"            = "-conf /etc/coredns/Corefile"
      "uid"                  = 1002
      "gid"                  = 100
      "environment TZ value" = "Asia/Shanghai"
      # "network coredns address" = "172.16.3.10"

      "volume coredns source"      = "/etc/coredns"
      "volume coredns destination" = "/etc/coredns"
    }
  }
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
    web_frontend = {
      # when send doh request to doh server by ip address,
      # it means no SNI information in the tcp request,
      # have to set default backend for this kind of request in haproxy
      path = "load-balancing haproxy service tcp443 backend"
      configs = {
        "" = "coredns_ext_http"
      }
    }
    web_backend = {
      path = "load-balancing haproxy backend coredns_ext_http"
      configs = {
        "mode" = "tcp"
        # "server vyos address" = "172.16.3.10"
        "server vyos port"    = "44353"
        "server vyos address" = "127.0.0.1"
      }
    }
    # api_frontend = {
    #   path = "load-balancing haproxy service tcp44353"
    #   configs = {
    #     "listen-address"         = "127.0.0.1"
    #     "port"                   = "44353"
    #     "mode"                   = "http"
    #     "ssl certificate"        = "coredns.vyos"
    #     "rule 10 url-path exact" = "/dns-query"
    #     "rule 10 set backend"    = "coredns_doh"
    #   }
    # }
    # api_backend = {
    #   path = "load-balancing haproxy backend coredns_doh"
    #   configs = {
    #     "mode"                   = "tcp"
    #     "server coredns address" = "172.16.3.10"
    #     "server coredns port"    = "443"
    #   }
    # }
  }
  path    = each.value.path
  configs = each.value.configs
}
