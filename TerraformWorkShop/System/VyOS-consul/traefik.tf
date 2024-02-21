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
      templatefile("${path.root}/consul/init.sh", {
        dirs        = self.triggers.dirs
        chown_user  = self.triggers.chown_user
        chown_group = self.triggers.chown_group
        chown_dir   = self.triggers.chown_dir
      })
    ]
  }
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
    tar_file_source = "https://github.com/traefik/traefik/releases/download/v2.11.0/traefik_v2.11.0_linux_amd64.tar.gz"
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
      templatefile_path = "${path.root}/traefik/traefik.yaml"
      templatefile_vars = {
        consul_client_addr   = "127.0.0.1:8500"
        consul_datacenter    = "dc1"
        consul_scheme        = "https"
        consul_tls_ca        = "/etc/traefik/certs/ca.crt"
        rootCA               = "/etc/traefik/certs/ca.crt"
        entrypoint_traefik   = "192.168.255.2:8080"
        entrypoint_web       = "192.168.255.2:80"
        entrypoint_websecure = "192.168.255.2:443"
        acme_ext_storage     = "/etc/traefik/acme/external.json"
        acme_int_caserver    = "https://step-ca.service.consul:8443/acme/acme/directory"
        acme_int_storage     = "/etc/traefik/acme/internal.json"
        access_log_path      = "/mnt/data/traefik/access.log"
      }
    }
    dynamic = {
      files = [
        {
          templatefile_path = "./traefik/dyn-traefik_dashboard.yaml"
          templatefile_vars = {
            sub_domain  = "traefik"
            base_domain = "service.consul"
            userpass    = "admin:$apr1$/F5ai.wT$7nFJWh4F7ZA0qoY.JZ69l1"
            certFile    = "/etc/traefik/certs/traefik.crt"
            keyFile     = "/etc/traefik/certs/traefik.key"
          }
        },
        {
          templatefile_path = "./traefik/dyn-toHttps.yaml"
          templatefile_vars = {
            permanent = "true"
          }
        },
      ]
      sub_dir = "dynamic"
    }
    tls = {
      ca_basename   = "ca.crt"
      ca_content    = data.terraform_remote_state.root_ca.outputs.root_cert_pem
      cert_basename = "traefik.crt"
      cert_content = join("\n",
        [
          lookup((data.terraform_remote_state.root_ca.outputs.signed_cert_pem), "traefik", null),
          data.terraform_remote_state.root_ca.outputs.root_cert_pem
        ]
      )
      key_basename = "traefik.key"
      key_content  = lookup((data.terraform_remote_state.root_ca.outputs.signed_key), "traefik", null)
      sub_dir      = "certs"
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
    systemd_unit_service = {
      templatefile_path = "${path.root}/traefik/traefik.service"
      templatefile_vars = {
        user                 = "vyos"
        group                = "users"
        LEGO_CA_CERTIFICATES = "/etc/traefik/certs/ca.crt"
      }
      target_path = "/etc/systemd/system/traefik.service"
    }
  }
}


# https://developer.hashicorp.com/consul/tutorials/get-started-vms/virtual-machine-gs-service-discovery#modify-service-definition-tags
resource "system_file" "traefik_consul" {
  depends_on = [system_service_systemd.traefik]
  path       = "${system_folder.consul_config.path}/traefik.hcl"
  content    = file("./traefik/traefik_consul.hcl")
  user       = "vyos"
  group      = "users"
}

resource "system_file" "consul-ui_consul" {
  depends_on = [system_service_systemd.traefik]
  path       = "${system_folder.consul_config.path}/consul-ui.hcl"
  content    = file("./consul/consul_consul.hcl")
  user       = "vyos"
  group      = "users"
}
