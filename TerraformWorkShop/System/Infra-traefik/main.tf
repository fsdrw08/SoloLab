resource "null_resource" "traefik_init" {
  connection {
    type     = "ssh"
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  triggers = {
    dirs        = "/mnt/data/traefik"
    chown_user  = "vyos"
    chown_group = "users"
    chown_dir   = "/mnt/data/traefik"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/traefik/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
}

# data "vault_pki_secret_backend_issuers" "root" {
#   backend = "pki/root"
# }

# data "vault_pki_secret_backend_issuer" "root" {
#   backend    = "pki/root"
#   issuer_ref = keys(jsondecode(data.vault_pki_secret_backend_issuers.root.key_info_json))[0]
# }

data "vault_generic_secret" "rootca" {
  path = "pki/root/cert/ca"
}

module "traefik" {
  depends_on = [null_resource.traefik_init]
  source     = "../modules/traefik"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  install = {
    # "https://github.com/traefik/traefik/releases/"
    tar_file_source = "http://sws.infra.sololab:4080/releases/traefik%5Fv2.11.0%5Flinux%5Famd64.tar.gz"
    tar_file_path   = "/home/vyos/traefik.tar.gz"
    bin_file_dir    = "/usr/bin"
  }
  runas = {
    take_charge = false
    user        = "vyos"
    group       = "users"
  }
  config = {
    static = {
      basename = "traefik.yaml"
      content = templatefile("${path.root}/traefik/traefik.yaml", {
        consul_client_addr   = "consul.service.consul:8501"
        consul_datacenter    = "dc1"
        consul_scheme        = "https"
        consul_tls_ca        = "/etc/traefik/certs/ca.crt"
        rootCA               = "/etc/traefik/certs/ca.crt"
        entrypoint_traefik   = "192.168.255.2:8080"
        entrypoint_web       = "192.168.255.2:80"
        entrypoint_websecure = "192.168.255.2:443"
        acme_ext_storage     = "/etc/traefik/acme/external.json"
        acme_int_caserver    = "https://vault.infra.sololab:8200/v1/pki/ica2_v1/acme/directory"
        acme_int_storage     = "/etc/traefik/acme/internal.json"
        access_log_path      = "/mnt/data/traefik/access.log"
      })
    }
    dynamic = {
      files = [
        # {
        #   basename = "dyn-default_tls.yaml"
        #   content = templatefile("./traefik/dyn-default_tls.yaml", {
        #     certFile = "/etc/traefik/certs/wildcard.crt"
        #     keyFile  = "/etc/traefik/certs/wildcard.key"
        #   })
        # },
        {
          basename = "dyn-traefik_dashboard.yaml"
          content = templatefile("./traefik/dyn-traefik_dashboard.yaml", {
            sub_domain  = "traefik"
            base_domain = "service.consul"
            userpass    = "admin:$apr1$/F5ai.wT$7nFJWh4F7ZA0qoY.JZ69l1"
          })
        },
        {
          basename = "dyn-toHttps.yaml"
          content = templatefile("./traefik/dyn-toHttps.yaml", {
            permanent = "true"
          })
        },
      ]
      sub_dir = "dynamic"
    }
    tls = {
      ca_basename = "ca.crt"
      ca_content  = data.vault_generic_secret.rootca.data.certificate
      # ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      # cert_basename = "wildcard.crt"
      # cert_content = join("\n",
      #   [
      #     lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "wildcard", null),
      #     # data.terraform_remote_state.root_ca.outputs.root_cert_pem
      #     data.terraform_remote_state.root_ca.outputs.int_ca_pem
      #   ]
      # )
      # key_basename = "wildcard.key"
      # key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "wildcard", null)
      sub_dir = "certs"
    }
    dir = "/etc/traefik"
  }
  storage = {
    dir_target = "/mnt/data/traefik"
    dir_link   = "/etc/traefik/acme"
  }
  service = {
    enabled = true
    status  = "started"
    systemd_service_unit = {
      content = templatefile("${path.root}/traefik/traefik.service", {
        user                 = "vyos"
        group                = "users"
        LEGO_CA_CERTIFICATES = "/etc/traefik/certs/ca.crt"
      })
      path = "/etc/systemd/system/traefik.service"
    }
  }
}

module "traefik_restart" {
  depends_on = [module.traefik]
  source     = "../modules/systemd_path"
  vm_conn = {
    host     = var.vm_conn.host
    port     = var.vm_conn.port
    user     = var.vm_conn.user
    password = var.vm_conn.password
  }
  systemd_path_unit = {
    content = templatefile("${path.root}/traefik/restart.path", {
      PathModified = [
        "/etc/traefik/traefik.yaml",
      ]
    })
    path = "/etc/systemd/system/traefik_restart.path"
  }
  systemd_service_unit = {
    content = templatefile("${path.root}/traefik/restart.service", {
      AssertPathExists = "/etc/systemd/system/traefik.service"
      target_service   = "traefik.service"
    })
    path = "/etc/systemd/system/traefik_restart.service"
  }
}

# https://developer.hashicorp.com/consul/tutorials/get-started-vms/virtual-machine-gs-service-discovery#modify-service-definition-tags
resource "system_file" "traefik_consul" {
  depends_on = [module.traefik]
  path       = "/etc/consul.d/traefik_consul.hcl"
  content    = file("${path.root}/traefik/traefik_consul.hcl")
  user       = "vyos"
  group      = "users"
}

# resource "system_file" "consul-ui_consul" {
#   depends_on = [module.traefik]
#   path       = "${system_folder.consul_config.path}/consul-ui.hcl"
#   content    = file("./consul/consul_consul.hcl")
#   user       = "vyos"
#   group      = "users"
# }
