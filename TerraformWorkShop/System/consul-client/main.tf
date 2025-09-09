resource "null_resource" "init" {
  connection {
    type     = "ssh"
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  triggers = {
    rootless_dirs = "${var.bin_dir},${var.data_dir}"
  }
  provisioner "remote-exec" {
    inline = [
      templatefile("${path.root}/attachments/init.sh", {
        rootless_dirs = split(",", self.triggers.rootless_dirs)
      })
    ]
  }
}

data "vault_kv_secret_v2" "cert" {
  mount = "kvv2-certs"
  name  = "root"
}

data "vault_kv_secret_v2" "encrypt" {
  mount = "kvv2-consul"
  name  = "key-gossip_encryption"
}

module "consul" {
  depends_on = [
    null_resource.init,
  ]
  source = "../modules/consul"
  vm_conn = {
    host     = var.prov_system.host
    port     = var.prov_system.port
    user     = var.prov_system.user
    password = var.prov_system.password
  }
  runas = {
    take_charge = false
    user        = "podmgr"
    uid         = "1001"
    group       = "podmgr"
    gid         = "1001"
  }
  install = [
    {
      # https://releases.hashicorp.com/consul/
      zip_file_source = "http://sws.infra.sololab:4080/releases/consul%5F1.18.0%5Flinux%5Famd64.zip"
      zip_file_path   = "/var/home/podmgr/nomad_1.10.4_linux_amd64.zip"
      bin_file_name   = "consul"
      bin_file_dir    = "${var.bin_dir}"
    }
  ]
  config = {
    main = {
      basename = "client.hcl"
      content = templatefile("./attachments/client.hcl", {
        bind_addr                     = "{{ GetInterfaceIP `eth0` }}"
        dns_addr                      = "{{ GetInterfaceIP `eth0` }}"
        client_addr                   = "{{ GetInterfaceIP `eth0` }}"
        enable_local_script_checks    = true
        data_dir                      = var.data_dir
        encrypt                       = data.vault_kv_secret_v2.encrypt.data["key"]
        tls_ca_file                   = "${var.XDG_CONFIG_HOME}/consul.d/tls/ca.crt"
        tls_cert_file                 = "${var.XDG_CONFIG_HOME}/consul.d/tls/client.pem"
        tls_key_file                  = "${var.XDG_CONFIG_HOME}/consul.d/tls/client-key.pem"
        tls_verify_incoming           = false
        tls_verify_outgoing           = true
        tls_verify_server_hostname    = true
        connect_enabled               = true
        acl_enabled                   = true
        acl_enable_token_persistence  = true
        acl_token_init_mgmt           = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
        acl_token_agent               = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
        acl_token_config_file_svc_reg = "e95b599e-166e-7d80-08ad-aee76e7ddf19"
      })
    }
    tls = {
      sub_dir     = "tls"
      ca_basename = "ca.crt"
      ca_content  = data.vault_kv_secret_v2.cert.data["ca"]
    }
    dir        = "${var.XDG_CONFIG_HOME}/consul.d"
    create_dir = true
  }
  service = {
    status = "start"
    auto_start = {
      enabled     = true
      link_path   = "${var.XDG_CONFIG_HOME}/systemd/user/default.target.wants/consul-client.service"
      link_target = "${var.XDG_CONFIG_HOME}/systemd/user/consul-client.service"
    }
    systemd_service_unit = {
      content = templatefile("${path.root}/attachments/consul-client.service", {
        bin_path           = "${var.bin_dir}/consul"
        config_file        = "${var.XDG_CONFIG_HOME}/consul.d/client.hcl"
        config_dir         = "/var/home/podmgr/consul-services"
        ExecStartPreConsul = "curl -fLsSk --retry-all-errors --retry 5 --retry-delay 30 https://127.0.0.1:8501/v1/catalog/services"
      })
      path = "${var.XDG_CONFIG_HOME}/systemd/user/consul-client.service"
    }
  }
}
